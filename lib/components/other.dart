import 'package:flutter/material.dart';

class Diaf extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(children: [
       const SizedBox(height: 20),
                const Text(
                  'Quel moyen de transport ?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Handle Taxi bokko selection
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Column(
                            children: [
                              Icon(Icons.local_taxi, color: Colors.yellow, size: 40),
                              SizedBox(height: 10),
                              Text(
                                'Taxi bokko',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Handle VTC selection
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Column(
                            children: [
                              Icon(Icons.directions_car, color: Colors.blue, size: 40),
                              SizedBox(height: 10),
                              Text(
                                'VTC',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle "Rechercher les voitures" action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Rechercher les voitures',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              
    ]
    );

  }
}