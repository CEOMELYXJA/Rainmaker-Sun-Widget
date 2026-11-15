# Rainmaker Sun Widget — Notre Soleil et Veille solaire

Deux widgets [Rainmeter](https://www.rainmeter.net/) pour Windows : **Notre Soleil**, au format de Notre planète, et **Veille solaire**, au format de Veille cosmique. Les panneaux sont indépendants, partagent leurs données et restent configurables par clic droit (petit, moyen, grand). Le bouton ↻ actualise les données ; la mise à jour est aussi automatique au premier lancement et toutes les cinq minutes.

## Installation

1. Installer Rainmeter si nécessaire, puis copier le dossier `RainmakerSunWidget` dans `Documents\Rainmeter\Skins`.
2. Dans **Gérer Rainmeter**, actualiser la liste des skins. Ouvrir `RainmakerSunWidget > SoleilCompact > Soleil.ini`, puis `RainmakerSunWidget > VeilleSolaire > Veille.ini`.
3. Déplacer les deux widgets sur l'écran voulu. Cliquer sur ↻ pour actualiser immédiatement ; le premier chargement peut prendre quelques secondes.

Une connexion Internet est nécessaire. Si une mesure est indisponible ou trop ancienne, elle apparaît sous forme de tirets ; survoler une ligne affiche l'heure UTC et l'état de sa source. L'image peut être différée et sa date correspond au téléchargement, pas nécessairement à la prise de vue.

## Sources et limites

- [NASA SDO, image AIA 304 Å](https://sdo.gsfc.nasa.gov/data/) : image ultraviolette colorisée, différente de la couleur visible à l'œil nu.
- [NOAA Space Weather Prediction Center](https://www.swpc.noaa.gov/content/data-access) : classe du flux de rayons X GOES, classe et heure du dernier maximum d'éruption communiqué par ce flux, vitesse et composante Bz du vent solaire près de la Terre, et flux radio F10,7. Le dernier maximum est un événement daté et ne représente pas la classe courante.
- Les indicateurs ne sont pas des prévisions ni des mesures locales. La classe de rayons X et les mesures du vent sont masquées si leurs dates dépassent respectivement 60 et 90 minutes ; le flux F10,7 est masqué après 72 heures.

`donnees.inc` est un état initial régénéré à chaque actualisation. L'image téléchargée `@Resources/Images/soleil.jpg` et les fichiers temporaires sont générés localement et exclus du dépôt. Les requêtes se font directement auprès de la NOAA et de la NASA.

## Attribution et licence

Le panneau compact reprend la structure de **Planète compacte**, adaptation de **Jord** par **crosseout**, sous licence [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/). Le présent projet est distribué selon cette même licence. Les données et images NASA/NOAA restent soumises aux conditions de leurs fournisseurs et ne sont pas incluses dans le dépôt.
