import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/services/car_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';

class CarAssignmentDialog extends StatefulWidget {
  final Function(VoitureModel car) onCarSelected;

  const CarAssignmentDialog({
    super.key,
    required this.onCarSelected,
  });

  @override
  State<CarAssignmentDialog> createState() => _CarAssignmentDialogState();
}

class _CarAssignmentDialogState extends State<CarAssignmentDialog> {
  VoitureModel? selectedCar;
  List<VoitureModel> cars = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      cars = await CarService().getAllVoitures();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors du chargement des voitures';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, size: 28),
                const SizedBox(width: 16),
                const Text(
                  'Sélectionner une voiture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadCars,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            else if (cars.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Aucune voiture disponible',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cars.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    final isSelected = selectedCar?.idVoiture == car.idVoiture;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isSelected ? AppColors.green : Colors.grey[200],
                        child: Icon(
                          Icons.directions_car,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      title: Text(
                        car.marque,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Marque: ${car.marque}'),
                          Text('Places: ${car.nombreDePlace}'),
                          Builder(
                            builder: (context) {
                              return FutureBuilder(
                                future:
                                    UserService().getUserById(car.idChauffeur!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    final driver = snapshot.data!;
                                    return Text(
                                      'Chauffeur: ${driver.prenom} ${driver.nom}',
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      selected: isSelected,
                      selectedTileColor: AppColors.green.withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          selectedCar = car;
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: selectedCar == null
                      ? null
                      : () {
                          widget.onCarSelected(selectedCar!);
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Confirmer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
