import 'package:boulder_competition/features/rankings/data/ranking_qualification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationOverview {
  const NotificationOverview({
    required this.competitionId,
    required this.isTurn,
    required this.registeredRecipients,
    required this.firstTurnRecipients,
    required this.secondTurnRecipients,
    required this.finalistRecipients,
    required this.finalistLimit,
  });

  final String competitionId;
  final bool isTurn;
  final int registeredRecipients;
  final int firstTurnRecipients;
  final int secondTurnRecipients;
  final int finalistRecipients;
  final int finalistLimit;
}

class NotificationSendResult {
  const NotificationSendResult({required this.sent});

  final int sent;
}

class NotificationService {
  NotificationService({
    SupabaseClient? client,
    RankingQualificazioneService? rankingService,
  }) : _client = client ?? Supabase.instance.client,
       _rankingService = rankingService ?? RankingQualificazioneService();

  final SupabaseClient _client;
  final RankingQualificazioneService _rankingService;

  Future<NotificationOverview> getOverview() async {
    final competition = await _client
        .from('competitions')
        .select('id, nr_finalisti, is_turn')
        .eq('fl_gara_chiusa', false)
        .order('dt_gara')
        .limit(1)
        .maybeSingle();

    if (competition == null) {
      throw StateError('No open competition found');
    }

    final competitionId = competition['id'] as String;
    final registrations = await _client
        .from('registrations')
        .select('profile_id, is_first_turn, is_second_turn, sesso')
        .eq('competition_id', competitionId);
    final registeredProfiles = _profileIds(registrations);
    final firstTurnProfiles = _profileIds(
      registrations.where((row) => row['is_first_turn'] == true).toList(),
    );
    final secondTurnProfiles = _profileIds(
      registrations.where((row) => row['is_second_turn'] == true).toList(),
    );

    final finalistLimit = (competition['nr_finalisti'] as num?)?.toInt() ?? 0;
    final rankings = await _rankingService.getRankings(competitionId);
    final registrationIds = [
      ...rankings.where((ranking) => ranking.sesso == 'M').take(finalistLimit),
      ...rankings.where((ranking) => ranking.sesso == 'F').take(finalistLimit),
    ].map((ranking) => ranking.registrationId).toList();
    final finalistProfiles = await _profilesForRegistrationIds(registrationIds);

    return NotificationOverview(
      competitionId: competitionId,
      isTurn: competition['is_turn'] as bool? ?? false,
      registeredRecipients: registeredProfiles.length,
      firstTurnRecipients: firstTurnProfiles.length,
      secondTurnRecipients: secondTurnProfiles.length,
      finalistRecipients: finalistProfiles.length,
      finalistLimit: finalistLimit,
    );
  }

  Future<NotificationSendResult> send({
    required String type,
    required String titleIt,
    required String bodyIt,
    required String titleEn,
    required String bodyEn,
    String? turn,
  }) async {
    final response = await _client.functions.invoke(
      'send-push-notification',
      body: {
        'type': type,
        'titleIt': titleIt,
        'bodyIt': bodyIt,
        'titleEn': titleEn,
        'bodyEn': bodyEn,
        'turn': ?turn,
      },
    );
    final data = response.data;
    final sent = data is Map ? (data['sent'] as num?)?.toInt() ?? 0 : 0;
    return NotificationSendResult(sent: sent);
  }

  Future<Set<String>> _profilesForRegistrationIds(
    List<String> registrationIds,
  ) async {
    if (registrationIds.isEmpty) return {};
    final rows = await _client
        .from('registrations')
        .select('profile_id')
        .inFilter('id', registrationIds);
    return _profileIds(rows);
  }

  Set<String> _profileIds(List<dynamic> rows) => rows
      .map((row) => row['profile_id'] as String?)
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toSet();
}