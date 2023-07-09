import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/home/advice/advice_home.dart';
import 'package:farkha_app/view/widget/home/circle_master/master_list.dart';
import 'package:farkha_app/view/widget/drawer/my_drawer.dart';
import 'package:farkha_app/view/widget/home/table_home/table_home.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    initBannerAd();
  }

  late BannerAd bannerAd;
  bool isAdLoaded = false;
  String  adUnit = 'ca-app-pub-3940256099942544/6300978111';

  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnit,
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          isAdLoaded = true;
        });
      }, onAdFailedToLoad: ((ad, error) {
        ad.dispose();
        // ignore: avoid_print
        print(error);
      })),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.7,
          child: const MyDrawer(),
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: scaColor,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(DateFormat('y/MM/dd').format(DateTime.now())),
              ),
            )
          ],
        ),
        body: Column(
          children: const [
            MasterList(),
            AdviceScroll(),
            Expanded(child: TableHome()),
            
          ],
        ),
        bottomNavigationBar: isAdLoaded
            ? SizedBox(
                height: bannerAd.size.height.toDouble(),
                width: bannerAd.size.width.toDouble(),
                child: AdWidget(ad: bannerAd),
              )
            : const SizedBox(),
      ),
    );
  }
}
