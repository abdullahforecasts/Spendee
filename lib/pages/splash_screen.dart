import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pushReplacementNamed(context, '/launch');
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00D09E),
      body: Container(
        //fill the entire screen
        width: double.infinity,
        height: double.infinity,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            //apni app ka logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                  image: DecorationImage(

                    image: AssetImage('assets/hand_coin.png'),
                    fit: BoxFit.cover,

                  )
              ),
            ),



            const SizedBox(height: 30),




            const Text(
              'Spendee.',
              style:TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.bold,
                letterSpacing:  1,

              ),
            ),


            const SizedBox(height: 40),
            //loading  bar
            const SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

