// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mergelings';

  @override
  String get tagline => 'Fusiona, colecciona y llena cinco praderas mágicas.';

  @override
  String get navMeadow => 'Pradera';

  @override
  String get navCollection => 'Colección';

  @override
  String get navShop => 'Tienda';

  @override
  String get navMeadows => 'Praderas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get hearts => 'Corazones';

  @override
  String get gems => 'Gemas';

  @override
  String perMinute(String amount) {
    return '$amount/min';
  }

  @override
  String get basket => 'Cesta';

  @override
  String get hintDragToMerge =>
      '¡Arrastra dos amigos iguales para fusionarlos!';

  @override
  String get hintTapBasket => 'La cesta se llena sola: tócala para acelerarla.';

  @override
  String get hintBoardFull =>
      'Tu pradera está llena: fusiona o despide a alguien primero.';

  @override
  String get newDiscovery => '¡Nuevo amigo descubierto!';

  @override
  String discoveryReward(int gems) {
    return '+$gems gemas';
  }

  @override
  String tierLabel(int tier) {
    return 'Nivel $tier';
  }

  @override
  String boardTileLabel(String name, int tier) {
    return '$name, nivel $tier';
  }

  @override
  String get boardMysteryLabel => 'Cesta misteriosa, sin abrir';

  @override
  String get sell => 'Despedir';

  @override
  String sellFor(String amount) {
    return 'Despedir por $amount';
  }

  @override
  String get sellTitle => '¿Mandar a este amigo a casa?';

  @override
  String sellBody(String amount) {
    return 'Recibirás $amount corazones.';
  }

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopFriends => 'Amigos';

  @override
  String get shopBoosts => 'Mejoras';

  @override
  String get buy => 'Comprar';

  @override
  String get notEnoughHearts => 'No tienes suficientes corazones.';

  @override
  String get notEnoughGems => 'No tienes suficientes gemas.';

  @override
  String get expandMeadow => 'Ampliar pradera';

  @override
  String get expandMeadowBody => 'Desbloquea otra fila de espacio.';

  @override
  String get meadowFullyExpanded => 'Ampliada al máximo';

  @override
  String get shopAccessories => 'Accesorios';

  @override
  String get accessoryTitle => 'Accesorio';

  @override
  String get accessoryNone => 'Ninguno';

  @override
  String get accessoryOwned => 'Comprado';

  @override
  String get accessoryOwnedBody =>
      'Póntelo a cualquier amigo desde su ficha de colección.';

  @override
  String accessoryLocked(int count) {
    return 'Descubre $count amigos para desbloquearlo.';
  }

  @override
  String accessoryBought(String name) {
    return '¡$name ya está en tu armario!';
  }

  @override
  String get accessoryEmptyHint =>
      'Compra accesorios en la tienda para vestir a tus amigos.';

  @override
  String get accessoryFlowerCrown => 'Corona de flores';

  @override
  String get accessoryBowTie => 'Pajarita';

  @override
  String get accessoryPartyHat => 'Gorro de fiesta';

  @override
  String get accessoryScarf => 'Bufanda calentita';

  @override
  String get accessoryTopHat => 'Sombrero de copa';

  @override
  String get accessorySunglasses => 'Gafas de sol';

  @override
  String get accessoryCape => 'Capa de héroe';

  @override
  String get accessoryHeadphones => 'Auriculares';

  @override
  String get accessoryCrown => 'Corona dorada';

  @override
  String get boostTitle => 'Corazones dobles';

  @override
  String boostBody(int minutes) {
    return 'Duplica todos los corazones durante $minutes minutos.';
  }

  @override
  String boostActive(String time) {
    return 'Corazones dobles: quedan $time';
  }

  @override
  String get basketBoostTitle => 'Cesta veloz';

  @override
  String basketBoostBody(int times, int minutes) {
    return 'La cesta se llena $times× más rápido durante $minutes minutos.';
  }

  @override
  String basketBoostActive(String time) {
    return 'Cesta veloz: quedan $time';
  }

  @override
  String get giftTitle => 'Amigo gratis';

  @override
  String get giftBody => 'Mira un vídeo corto y consigue un amigo gratis.';

  @override
  String get mysteryTitle => '¡Una cesta misteriosa!';

  @override
  String get mysteryBody => 'Algo se mueve dentro. Elige cómo abrirla.';

  @override
  String get mysteryOpenNow => 'Abrir ahora';

  @override
  String get mysteryLater => 'Dejarla por ahora';

  @override
  String mysteryTierRange(int min, int max) {
    return 'Un amigo de nivel $min–$max';
  }

  @override
  String mysteryGranted(String name) {
    return '¡$name salió de la cesta!';
  }

  @override
  String get watchAd => 'Ver vídeo';

  @override
  String get adNotReady =>
      'No hay vídeo disponible ahora mismo. Inténtalo en un momento.';

  @override
  String get adRewardGranted => '¡Recompensa recogida!';

  @override
  String get welcomeBackTitle => '¡Bienvenido de nuevo!';

  @override
  String welcomeBackBody(String amount) {
    return 'Tu pradera ganó $amount corazones mientras no estabas.';
  }

  @override
  String get collect => 'Recoger';

  @override
  String get collectDouble => 'Recoger el doble';

  @override
  String get collectionTitle => 'Colección';

  @override
  String collectionProgress(int found, int total) {
    return '$found de $total descubiertos';
  }

  @override
  String get undiscovered => 'Aún sin descubrir';

  @override
  String get meadowsTitle => 'Praderas';

  @override
  String meadowLocked(int tier, String meadow) {
    return 'Descubre el nivel $tier en $meadow para desbloquear.';
  }

  @override
  String get meadowUnlocked => '¡Desbloqueada!';

  @override
  String get enterMeadow => 'Entrar';

  @override
  String get worldDay => 'Pradera del Día';

  @override
  String get worldNight => 'Pradera Nocturna';

  @override
  String get worldWater => 'Pradera Marina';

  @override
  String get worldMythical => 'Pradera Mítica';

  @override
  String get worldPrehistoric => 'Pradera Dino';

  @override
  String get worldDayDesc => 'Hierba soleada y amigos del bosque.';

  @override
  String get worldNightDesc => 'Criaturas de luna y viajeros estelares.';

  @override
  String get worldWaterDesc => 'Del arrecife hasta el azul profundo.';

  @override
  String get worldMythicalDesc => 'Folclore, leyenda y dragones ancestrales.';

  @override
  String get worldPrehistoricDesc => 'Gigantes fósiles de un mundo perdido.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSound => 'Efectos de sonido';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsAdPrivacy => 'Privacidad de anuncios';

  @override
  String get settingsTerms => 'Términos de uso';

  @override
  String get settingsRate => 'Valorar Mergelings';

  @override
  String get settingsReset => 'Reiniciar progreso';

  @override
  String get settingsResetBody =>
      'Esto borra para siempre cada pradera, amigo y corazón. No se puede deshacer.';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsSystemLanguage => 'Idioma del sistema';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get loading => 'Cargando…';
}
