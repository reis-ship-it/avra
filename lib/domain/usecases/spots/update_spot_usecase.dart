import 'package:spots/core/models/spot.dart';
import 'package:spots/domain/repositories/spots_repository.dart';

class UpdateSpotUseCase {
  final SpotsRepository spotsRepository;

  UpdateSpotUseCase(this.spotsRepository);

  Future<Spot> call(Spot spot) async {
    return await spotsRepository.updateSpot(spot);
  }
} 