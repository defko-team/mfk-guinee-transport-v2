import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Politique de confidentialité'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTitle('MFK_GUINEE_TRANSPORT'),
              _buildSubtitle(
                  'Politique de Confidentialité de MFK_GUINEE_TRANSPORT'),
              _buildSection('1. Introduction',
                  'Chez MFK_GUINEE_TRANSPORT, nous nous engageons à protéger et à respecter la vie privée de nos clients. Cette politique de confidentialité explique comment nous collectons, utilisons et protégeons vos données personnelles.'),
              _buildSection('2. Types de Données Collectées', '''
Nous collectons les types de données suivants lors de l'utilisation de nos services :
• Données d'identification : nom, prénom, adresse, numéro de téléphone, adresse e-mail
• Données de transport : informations relatives à vos trajets (dates, lieux de départ et d'arrivée, itinéraire)
• Données de paiement : informations bancaires ou liées aux transactions
• Données de géolocalisation : pour vous fournir nos services de transport en temps réel
• Données de navigation : cookies et autres informations liées à l'utilisation de notre application'''),
              _buildSection('3. Objectifs de la Collecte des Données', '''
Nous collectons vos données personnelles pour les raisons suivantes :
• Exécution de contrats : gérer vos réservations et trajets
• Amélioration des services : analyser et optimiser nos services
• Sécurité et prévention de la fraude
• Obligations légales'''),
              _buildSection('4. Base Légale pour le Traitement des Données', '''
Nous traitons vos données personnelles sur les bases légales suivantes :
• Exécution d'un contrat
• Consentement
• Obligations légales
• Intérêts légitimes'''),
              _buildSection('5. Partage des Données avec des Tiers', '''
Nous pouvons partager vos données avec :
• Prestataires de services
• Partenaires commerciaux
• Autorités légales (si requis)'''),
              _buildSection('6. Protection des Données',
                  'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles pour protéger vos données personnelles.'),
              _buildSection('7. Durée de Conservation des Données', '''
• Données liées aux trajets : 12 mois
• Données financières : 5 ans (conformément à la législation guinéenne)'''),
              _buildSection('8. Vos Droits', '''
Vous disposez des droits suivants :
• Droit d'accès
• Droit de rectification
• Droit à l'effacement
• Droit à la portabilité
• Droit d'opposition'''),
              _buildSection('9. Contact', '''
MFK_GUINEE_TRANSPORT
Email : contact@mfk-guinee-transport.com
Téléphone : +224 XX XX XX XX
Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'''),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.green,
        ),
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
