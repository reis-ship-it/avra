import 'package:avrai/core/models/spot.dart';
import 'package:avrai/domain/repositories/spots_repository.dart';

class UpdateSpotUseCase {
  final SpotsRepository spotsRepository;

  UpdateSpotUseCase(this.spotsRepository);

  Future<Spot> call(Spot spot) async {
    return await spotsRepository.updateSpot(spot);
  }
} 