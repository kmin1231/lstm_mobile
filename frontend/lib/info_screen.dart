import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:frontend/constants.dart';


class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key});  

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: dialogColor,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        width: MediaQuery.of(context).size.width * 0.75,
        height: 584,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Application Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.finance, size: 25),
                SizedBox(width: 10),
                Text(
                  'PrediTock',
                  style: appInfoStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),
            Text(appNameInfo, style: appInfoStyle.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 16,
            )),

            SizedBox(height: 20),

            Text(
              appInfoText,
              textAlign: TextAlign.center,
              style: appInfoStyle
            ),

            Text(
              appInfoTextDetail,
              textAlign: TextAlign.center,
              style: appInfoStyle
            ),

            Text(
              appFunctions,
              textAlign: TextAlign.center,
              style: appInfoStyle
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: infoTextColor,
                ),
                ),
            ),
          ]
        )
      )
    );
  }
}


void _connectGitHub() async {
  const githubURL = 'https://github.com/kmin1231';
  final Uri githubUri = Uri.parse(githubURL);
  if (await canLaunchUrl(githubUri)) {
    await launchUrl(githubUri);
  } else {
    throw 'Could not launch $githubURL';
  }
}

class DevInfoDialog extends StatelessWidget {
  const DevInfoDialog({super.key});  

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: dialogColor,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        width: MediaQuery.of(context).size.width * 0.75,
        height: 584,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Development Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/dart.png', 
                  height: devInfoSize, width: devInfoSize,
                ),
                SizedBox(width: 17),
                Image.asset(
                  'lib/assets/images/javascript.png',
                  height: devInfoSize, width: devInfoSize,
                ),
                SizedBox(width: 17),
                Image.asset(
                  'lib/assets/images/python.png',
                  height: devInfoSize, width: devInfoSize,
                ),
              ],
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/flutter.png',
                  height: devInfoSize, width: devInfoSize,
                ),

                SizedBox(width: 17),

                Image.asset(
                  'lib/assets/images/node.js.png',
                  height: devInfoSize, width: devInfoSize,
                ),

                SizedBox(width: 17),

                Image.asset(
                  'lib/assets/images/firestore.png', 
                  height: devInfoSize, width: devInfoSize,
                ),

                SizedBox(width: 17),

                Image.asset(
                  'lib/assets/images/sqlite.png',
                  height: devInfoSize, width: devInfoSize,
                ),
              ],
            ),

            SizedBox(height: 50),

            Text(
              'MIT License',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                color: infoTextColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 18),

            Text(
              'Copyright (c) 2024',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 17,
                color: infoTextColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 18),

            GestureDetector(
              onTap: _connectGitHub,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.github, size: 30),
                  SizedBox(width: 8),
                  Text(
                    'Eden Min Kim',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 17,
                      color: infoTextColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: infoTextColor,
                ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}


class GenInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('General Info'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Center(child: Text('General Info', style: TextStyle(color: Colors.white))),
    );
  }
}