import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:frontend/constants.dart';


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

            SizedBox(height: 30),

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
                      fontSize: 16,
                      color: infoTextColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 17),
            
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