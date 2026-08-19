// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LPt extends L {
  LPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Mergelings';

  @override
  String get tagline => 'Junte, colecione e preencha cinco prados mágicos.';

  @override
  String get navMeadow => 'Prado';

  @override
  String get navCollection => 'Coleção';

  @override
  String get navShop => 'Loja';

  @override
  String get navMeadows => 'Prados';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get hearts => 'Corações';

  @override
  String get gems => 'Gemas';

  @override
  String perMinute(String amount) {
    return '$amount/min';
  }

  @override
  String get basket => 'Cesta';

  @override
  String get hintDragToMerge => 'Arraste dois amigos iguais para juntá-los!';

  @override
  String get hintTapBasket =>
      'A cesta enche sozinha — toque nela para acelerar.';

  @override
  String get hintBoardFull =>
      'Seu prado está cheio — junte ou dispense alguém primeiro.';

  @override
  String get newDiscovery => 'Novo amigo descoberto!';

  @override
  String discoveryReward(int gems) {
    return '+$gems gemas';
  }

  @override
  String tierLabel(int tier) {
    return 'Nível $tier';
  }

  @override
  String boardTileLabel(String name, int tier) {
    return '$name, nível $tier';
  }

  @override
  String get boardMysteryLabel => 'Cesta misteriosa, ainda fechada';

  @override
  String get sell => 'Dispensar';

  @override
  String sellFor(String amount) {
    return 'Dispensar por $amount';
  }

  @override
  String get sellTitle => 'Mandar este amigo para casa?';

  @override
  String sellBody(String amount) {
    return 'Você receberá $amount corações.';
  }

  @override
  String get shopTitle => 'Loja';

  @override
  String get shopFriends => 'Amigos';

  @override
  String get shopBoosts => 'Turbos';

  @override
  String get buy => 'Comprar';

  @override
  String get notEnoughHearts => 'Corações insuficientes.';

  @override
  String get notEnoughGems => 'Gemas insuficientes.';

  @override
  String get expandMeadow => 'Ampliar prado';

  @override
  String get expandMeadowBody => 'Libere mais uma fileira de espaço.';

  @override
  String get meadowFullyExpanded => 'Totalmente ampliado';

  @override
  String get shopAccessories => 'Acessórios';

  @override
  String get accessoryTitle => 'Acessório';

  @override
  String get accessoryNone => 'Nenhum';

  @override
  String get accessoryOwned => 'Comprado';

  @override
  String get accessoryOwnedBody =>
      'Coloque em qualquer amigo pela ficha da coleção.';

  @override
  String accessoryLocked(int count) {
    return 'Descubra $count amigos para desbloquear.';
  }

  @override
  String accessoryBought(String name) {
    return '$name entrou no seu guarda-roupa!';
  }

  @override
  String get accessoryEmptyHint =>
      'Compre acessórios na loja para vestir seus amigos.';

  @override
  String get accessoryFlowerCrown => 'Coroa de flores';

  @override
  String get accessoryBowTie => 'Gravata-borboleta';

  @override
  String get accessoryPartyHat => 'Chapéu de festa';

  @override
  String get accessoryScarf => 'Cachecol quentinho';

  @override
  String get accessoryTopHat => 'Cartola';

  @override
  String get accessorySunglasses => 'Óculos de sol';

  @override
  String get accessoryCape => 'Capa de herói';

  @override
  String get accessoryHeadphones => 'Fones de ouvido';

  @override
  String get accessoryCrown => 'Coroa dourada';

  @override
  String get boostTitle => 'Corações em dobro';

  @override
  String boostBody(int minutes) {
    return 'Dobra todos os corações por $minutes minutos.';
  }

  @override
  String boostActive(String time) {
    return 'Corações em dobro — falta $time';
  }

  @override
  String get basketBoostTitle => 'Cesta veloz';

  @override
  String basketBoostBody(int times, int minutes) {
    return 'A cesta enche $times× mais rápido por $minutes minutos.';
  }

  @override
  String basketBoostActive(String time) {
    return 'Cesta veloz — falta $time';
  }

  @override
  String get giftTitle => 'Amigo grátis';

  @override
  String get giftBody => 'Assista a um vídeo curto e ganhe um amigo grátis.';

  @override
  String get mysteryTitle => 'Uma cesta misteriosa!';

  @override
  String get mysteryBody => 'Algo se mexe lá dentro. Escolha como abri-la.';

  @override
  String get mysteryOpenNow => 'Abrir agora';

  @override
  String get mysteryLater => 'Deixar para depois';

  @override
  String mysteryTierRange(int min, int max) {
    return 'Um amigo dos níveis $min–$max';
  }

  @override
  String mysteryGranted(String name) {
    return '$name saiu da cesta!';
  }

  @override
  String get watchAd => 'Assistir vídeo';

  @override
  String get adNotReady =>
      'Nenhum vídeo disponível agora. Tente de novo em instantes.';

  @override
  String get adRewardGranted => 'Recompensa coletada!';

  @override
  String get welcomeBackTitle => 'Bem-vindo de volta!';

  @override
  String welcomeBackBody(String amount) {
    return 'Seu prado rendeu $amount corações enquanto você esteve fora.';
  }

  @override
  String get collect => 'Coletar';

  @override
  String get collectDouble => 'Coletar em dobro';

  @override
  String get collectionTitle => 'Coleção';

  @override
  String collectionProgress(int found, int total) {
    return '$found de $total descobertos';
  }

  @override
  String get undiscovered => 'Ainda não descoberto';

  @override
  String get meadowsTitle => 'Prados';

  @override
  String meadowLocked(int tier, String meadow) {
    return 'Descubra o nível $tier em $meadow para liberar.';
  }

  @override
  String get meadowUnlocked => 'Liberado!';

  @override
  String get enterMeadow => 'Entrar';

  @override
  String get worldDay => 'Prado do Dia';

  @override
  String get worldNight => 'Prado da Noite';

  @override
  String get worldWater => 'Prado do Mar';

  @override
  String get worldMythical => 'Prado Mítico';

  @override
  String get worldPrehistoric => 'Prado Dino';

  @override
  String get worldDayDesc => 'Grama ensolarada e amigos da floresta.';

  @override
  String get worldNightDesc => 'Bichos ao luar e viajantes estelares.';

  @override
  String get worldWaterDesc => 'Do recife raso até o azul profundo.';

  @override
  String get worldMythicalDesc => 'Folclore, lenda e dragões ancestrais.';

  @override
  String get worldPrehistoricDesc => 'Gigantes fósseis de um mundo perdido.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSound => 'Efeitos sonoros';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsHaptics => 'Vibração';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get settingsAdPrivacy => 'Privacidade de anúncios';

  @override
  String get settingsTerms => 'Termos de uso';

  @override
  String get settingsRate => 'Avaliar Mergelings';

  @override
  String get settingsReset => 'Reiniciar progresso';

  @override
  String get settingsResetBody =>
      'Isto apaga para sempre cada prado, amigo e coração. Não dá para desfazer.';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsSystemLanguage => 'Padrão do sistema';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get loading => 'Carregando…';
}
