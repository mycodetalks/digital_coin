import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digital_coin/pages/details_page.dart';
import 'package:digital_coin/services/http_service.dart';
import 'package:digital_coin/widgets/phone_tablet_builder.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedCoin = 'stellar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CoinDropList(
                selectedCoin: selectedCoin,
                onCoinSelected: (String? coin) {
                  setState(() => selectedCoin = coin!);
                },
              ),
            ),
            Expanded(
              child: CoinDetails(coin: selectedCoin),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class CoinDetails extends StatefulWidget {
  const CoinDetails({
    super.key,
    required this.coin,
  });

  final String coin;

  @override
  State<CoinDetails> createState() => _CoinDetailsState();
}

class _CoinDetailsState extends State<CoinDetails> {
  late ApiService api;
  late Future<CoinResponse> _futureResponse;

  @override
  void initState() {
    super.initState();
    api = GetIt.instance.get<ApiService>();
    _futureResponse = api.getCoin(widget.coin);
  }

  @override
  void didUpdateWidget(covariant CoinDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coin != oldWidget.coin) {
      _futureResponse = api.getCoin(widget.coin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoinResponse>(
      future: _futureResponse,
      builder: (BuildContext context, AsyncSnapshot<CoinResponse> snapshot) {
        if (snapshot.hasData) {
          return _CoinInfo(
            data: snapshot.requireData,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}

@immutable
class CoinDropList extends StatelessWidget {
  const CoinDropList({
    super.key,
    required this.selectedCoin,
    required this.onCoinSelected,
  });

  final String? selectedCoin;
  final ValueChanged<String?> onCoinSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: selectedCoin,
        items: <DropdownMenuItem<String>>[
          for (final coin in const ['stellar', 'gmx', 'aptos', 'filecoin', 'tezos']) //
            DropdownMenuItem(
              value: coin,
              child: Text(
                coin,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        onChanged: onCoinSelected,
        dropdownColor: const Color.fromARGB(255, 183, 202, 228),
        iconSize: 30,
        icon: const Icon(
          Icons.arrow_drop_down_sharp,
          color: Colors.white,
        ),
      ),
    );
  }
}

@immutable
class _CoinInfo extends StatelessWidget {
  const _CoinInfo({
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final usdPrice = data["market_data"]["current_price"]["gbp"] as num;
    final change24h = data["market_data"]["price_change_percentage_24h"] as num;
    final exchangeRates = data["market_data"]["current_price"] as Map;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => DetailsPage(
                  rates: exchangeRates,
                ),
              ),
            );
          },
          child: Center(
            child: Image.network(
              data["image"]["large"] as String,
              height: 64.0,
            ),
          ),
        ),
        Text(
          "${usdPrice.toStringAsFixed(2)} GBP",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "${change24h.toString()} %",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: AboutCard(
            description: data["description"]["en"],
          ),
        ),
        const ConnectivityBanner(),
      ],
    );
  }
}

@immutable
class AboutCard extends StatelessWidget {
  const AboutCard({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return PhoneTabletBuilder(
      builder: (BuildContext context, bool isPhone, bool isPortrait, Widget? child) {
        final widthFactor = isPortrait ? 0.75 : 0.50;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: child,
          ),
        );
      },
      child: Material(
        color: const Color.fromARGB(124, 223, 224, 246),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            description,
            style: const TextStyle(color: Colors.black38),
          ),
        ),
      ),
    );
  }
}

@immutable
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final _connectivity = Connectivity();
  StreamSubscription? _connectivitySub;
  ConnectivityResult? _currentResult = ConnectivityResult.none;

  bool get isConnected => _currentResult != ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    initConnectivity();
  }

  Future<void> initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _onConnectivityChanged(result);
    if (mounted) {
      _connectivitySub = _connectivity //
          .onConnectivityChanged
          .listen(_onConnectivityChanged);
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    if (mounted) {
      setState(() => _currentResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return const SizedBox();
    }
    return const Material(
      color: Colors.red,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Text(
          'Please connect to the internet to use this app.',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
