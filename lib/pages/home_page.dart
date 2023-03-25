import 'dart:convert';
import 'package:digital_coin/pages/details_page.dart';
import 'package:digital_coin/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCoin = "stellar";
  double? kHeight, kWidth;
  HTTPService? http;
  @override
  void initState() {
    super.initState();
    http = GetIt.instance.get<HTTPService>();
  }

  @override
  Widget build(BuildContext context) {
    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            selectedCoinDropdown(),
            dataCoinWidget(),
          ],
        ),
      )),
    );
  }

  Widget selectedCoinDropdown() {
    List<String> coins = ["stellar", "gmx", "aptos", "filecoin", "tezos"];
    List<DropdownMenuItem<String>> items = coins
        .map((e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
        .toList();
    return DropdownButton(
      value: selectedCoin,
      items: items,
      onChanged: (dynamic value) {
        setState(() {
          selectedCoin = value;
        });
      },
      dropdownColor: const Color.fromARGB(255, 183, 202, 228),
      iconSize: 30,
      icon: const Icon(
        Icons.arrow_drop_down_sharp,
        color: Colors.white,
      ),
      underline: Container(),
    );
  }

  Widget dataCoinWidget() {
    return FutureBuilder(
        future: http!.get("coins/$selectedCoin"),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Map data = jsonDecode(
              snapshot.data.toString(),
            );
            num usdPrice = data["market_data"]["current_price"]["gbp"];
            num change24h = data["market_data"]["price_change_percentage_24h"];
            Map exchangeRates = data["market_data"]["current_price"];

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: coinPicWidget(
                    data["image"]["large"],
                  ),
                ),
                currentPriceWidget(usdPrice),
                percentageUpdateWidget(change24h),
                aboutCardWidget(data["description"]["en"]),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
        });
  }

  Widget currentPriceWidget(num rate) {
    return Text(
      "${rate.toStringAsFixed(2)} GBP",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget percentageUpdateWidget(num change) {
    return Text(
      "${change.toString()} %",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget coinPicWidget(String imgUrl) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: kHeight! * 0.02),
      height: kHeight! * 0.15,
      width: kWidth! * 0.15,
      decoration:
          BoxDecoration(image: DecorationImage(image: NetworkImage(imgUrl))),
    );
  }

  Widget aboutCardWidget(String description) {
    return Container(
      height: kHeight! * 0.28,
      width: kWidth! * 0.78,
      margin: EdgeInsets.symmetric(vertical: kHeight! * 0.05),
      padding: EdgeInsets.symmetric(
        vertical: kHeight! * 0.01,
        horizontal: kHeight! * 0.01,
      ),
      color: const Color.fromARGB(124, 223, 224, 246),
      child: Text(
        description,
        style: const TextStyle(color: Colors.black38),
      ),
    );
  }
}
