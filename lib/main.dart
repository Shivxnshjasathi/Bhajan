import 'dart:async';
import 'dart:io';
import 'package:bhajan/path.dart';
import 'package:bhajan/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fuzzy/fuzzy.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bhajan App',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class BhajanScreen extends StatefulWidget {
  const BhajanScreen({super.key});

  @override
  State<BhajanScreen> createState() => _BhajanScreenState();
}

class _BhajanScreenState extends State<BhajanScreen> {
  @override
  List<Map<String, String>> displayedPdfFiles = [];
  String searchQuery = "";
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    displayedPdfFiles = List.from(allPdfFiles);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;

      final fuzzy = Fuzzy(allPdfFiles.map((file) => file["name"]!).toList());
      final results = fuzzy.search(query);

      displayedPdfFiles = results
          .map((result) => allPdfFiles.firstWhere(
              (file) => file["name"] == result.item,
              orElse: () => {"name": "", "fileName": ""}))
          .toList();
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchQuery = "";
        displayedPdfFiles = List.from(allPdfFiles);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFfff8c3),
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset(
                  'assets/logo.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          title: isSearching
              ? TextField(
                  decoration: InputDecoration(
                    hintText: "Search Bhajans...",
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.poppins(color: Colors.white60),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: updateSearch,
                  autofocus: true,
                )
              : Text(
                  "भजनामृत",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
          backgroundColor: const Color(0xFFfe4c4d),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  isSearching ? Icons.close : LineIcons.search,
                  size: 28.0,
                  color: Colors.white,
                ),
                onPressed: toggleSearch,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "आत्म विभोर के सूत्र",
                style: GoogleFonts.poppins(
                    color: Color(0xFFaa3117),
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                "श्री श्री बाबा श्री जी",
                style: GoogleFonts.poppins(
                    color: Color(0xFFaa3117),
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: displayedPdfFiles.isEmpty
                    ? Center(
                        child: Text(
                          "No PDFs found",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayedPdfFiles.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: ListTile(
                                  title: Text(
                                    displayedPdfFiles[index]["name"]!,
                                    style: GoogleFonts.poppins(
                                        color: Color(0xFFaa3117),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  leading: Icon(
                                    LineIcons.fileInvoice,
                                    color: Color(0xFFfe4c4d),
                                  ),
                                  onTap: () async {
                                    String? filePath = await loadPDF(
                                        displayedPdfFiles[index]["fileName"]!);
                                    if (filePath != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PDFScreen(
                                            path: filePath,
                                            title: displayedPdfFiles[index]
                                                ["name"]!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ));
  }

  Future<String?> loadPDF(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File("${tempDir.path}/${assetPath.split('/').last}");
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      return file.path;
    } catch (e) {
      print("Error loading PDF: $e");
      return null;
    }
  }
}

class PDFScreen extends StatelessWidget {
  final String path;
  final String title;

  const PDFScreen({Key? key, required this.path, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFFfe4c4d),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              LineIcons.arrowLeft,
              color: Colors.yellow,
            ),
          ),
          title: Text(title,
              style: GoogleFonts.poppins(color: Colors.yellow, fontSize: 15))),
      body: PDFView(
        filePath: path,
        enableSwipe: true,
        swipeHorizontal: false,
        fitPolicy: FitPolicy.BOTH,
      ),
    );
  }
}
