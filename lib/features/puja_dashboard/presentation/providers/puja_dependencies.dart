import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/ai_extraction_datasource.dart';
import '../../data/datasources/puja_local_datasource.dart';
import '../../data/datasources/puja_remote_datasource.dart';
import '../../data/repositories/ai_extraction_repository_impl.dart';
import '../../data/repositories/puja_repository_impl.dart';
import '../../domain/repositories/ai_extraction_repository.dart';
import '../../domain/repositories/puja_repository.dart';

final pujaSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final pujaRemoteDatasourceProvider = Provider<PujaRemoteDatasource>((ref) {
  final client = ref.watch(pujaSupabaseClientProvider);
  return PujaRemoteDatasource(client);
});

final pujaLocalDatasourceProvider = Provider<PujaLocalDatasource>((ref) {
  return PujaLocalDatasource();
});

final pujaRepositoryProvider = Provider<PujaRepository>((ref) {
  final client = ref.watch(pujaSupabaseClientProvider);
  final remote = ref.watch(pujaRemoteDatasourceProvider);
  final local = ref.watch(pujaLocalDatasourceProvider);
  return PujaRepositoryImpl(client: client, remote: remote, local: local);
});

final aiExtractionRepositoryProvider = Provider<AiExtractionRepository>((ref) {
  final datasource = AiExtractionDatasourceFactory.create();
  return AiExtractionRepositoryImpl(datasource);
});
