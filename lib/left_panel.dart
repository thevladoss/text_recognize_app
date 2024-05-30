import 'package:flutter/material.dart';

class LeftPanel extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback pickFile;

  LeftPanel(
      {required this.imageUrl,
      required this.isLoading,
      required this.pickFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: isLoading ? null : pickFile,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: imageUrl == null
                ? Text(
                    'Выберите фотографию',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : pickFile,
                            child: Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
