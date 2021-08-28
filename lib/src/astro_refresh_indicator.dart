import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rive/rive.dart';

class AstroRefreshIndicator extends RefreshIndicator {
  const AstroRefreshIndicator({
    this.fit = BoxFit.cover,
    this.backgroundColor = const Color(0xFF43378D),
    Duration completeDuration = const Duration(milliseconds: 500),
    double height = 150,
    RefreshStyle refreshStyle = RefreshStyle.UnFollow,
    Key? key,
  }) : super(
          key: key,
          height: height,
          completeDuration: completeDuration,
          refreshStyle: refreshStyle,
        );

  final BoxFit fit;
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() {
    return _AstroRefreshIndicatorState();
  }
}

class _AstroRefreshIndicatorState extends RefreshIndicatorState<AstroRefreshIndicator> {
  late final Artboard _riveArtboard;
  late final StateMachineController _riveController;
  late final SMIInput<double> _pullAmountInput;
  late final SMIInput<bool> _isLoadingInput;

  bool _assetLoaded = false;
  double _innerHeight = 0;

  @override
  void initState() {
    super.initState();

    _initRive();
  }

  Future<void> _initRive() async {
    final file = await RiveFile.asset('packages/astro_refresh_indicator/assets/space_reload.riv');

    _riveArtboard = file.mainArtboard;
    _riveController = StateMachineController.fromArtboard(_riveArtboard, 'Reload')!;

    _riveArtboard.addController(_riveController);

    _pullAmountInput = _riveController.findInput<double>('Pull Amount')!;
    _isLoadingInput = _riveController.findInput<bool>('Is Loading')!;

    setState(() => _assetLoaded = true);
  }

  @override
  void onOffsetChange(double offset) {
    if (!_assetLoaded) {
      return;
    }

    if (offset < 0.0 || offset > widget.height) {
      return;
    }

    _updatePullAmount(offset);

    if (mode == RefreshStatus.idle) {
      setState(() => _innerHeight = offset);
    }
  }

  void _updatePullAmount(double offset) {
    if (_isLoadingInput.value) {
      return;
    }

    final pullAmount = 100.0 * offset / widget.height;

    _pullAmountInput.value = pullAmount;
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (!_assetLoaded) {
      return;
    }

    if (mode == RefreshStatus.canRefresh) {
      _isLoadingInput.value = true;
    }

    if (mode == RefreshStatus.completed || mode == RefreshStatus.idle) {
      _isLoadingInput.value = false;
    }
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    if (!_assetLoaded) {
      return const SizedBox();
    }

    return Container(
      height: _innerHeight,
      color: widget.backgroundColor,
      child: Rive(
        artboard: _riveArtboard,
        fit: widget.fit,
      ),
    );
  }
}
