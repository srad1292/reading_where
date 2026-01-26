import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reading_where/components/confirmation_dialog.dart';
import 'package:reading_where/components/error_dialog.dart';
import 'package:reading_where/enums/book_list_type.dart';
import 'package:reading_where/enums/asset_type.dart';
import 'package:reading_where/pages/book_list.dart';
import 'package:reading_where/components/location_expansion_tile.dart';
import 'package:reading_where/components/navigation_tile.dart';
import 'package:reading_where/service_locator.dart';
import 'package:reading_where/services/book_service.dart';
import 'components/success_dialog.dart';
import 'models/book.dart';
import 'models/import_result.dart';


class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  final BookService _bookService = serviceLocator.get<BookService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Reading Where?"),
        centerTitle: true,
          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                switch (value) {
                  case 'Import':
                    List<Book> importedData = await importBooks(context);
                    if(importedData.isNotEmpty) {
                      debugPrint("Got book data to import ${importedData.length} books");
                      debugPrint(importedData.first.toString());
                      ImportResult importResult = await _bookService.importBooks(importedData);
                      if(importResult.success) {
                        showSuccessDialog(context: context, title: "Import", body: "Imported ${importResult.inserted} books.\nSkipped ${importResult.skipped} books.");
                      } else {
                        showErrorDialog(context: context, body: "Failed to import books");
                      }
                    } else {
                      showConfirmationDialog(context: context, body: "No books to import");
                    }
                    break;
                  case 'ExportEmail':
                    // Export Data
                    List<Book> bookData = await _bookService.getSavedBooks();
                    if(bookData.isEmpty) {
                      await showErrorDialog(context: context, body: "No books to export");
                      break;
                    }
                    await _sendEmail(context, bookData);
                    break;
                }
              },
              itemBuilder: (context) =>
              [
                const PopupMenuItem(value: 'Import', child: Text('Import')),
                const PopupMenuItem(value: 'ExportEmail', child: Text('Export Email')),
              ],
            ),
          ]
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LocationExpansionTile(
                  title: "Global",
                  assetPath: 'assets/images/globe.png',
                  assetType: AssetType.png,
                  children: [
                    NavigationTile(text: "Country List", onTap: () => BookListNavigation(context, BookListType.country),),
                    NavigationTile(text: "Analytics", onTap: () => AnalyticsNavigation(),),
                  ]
              ),
              LocationExpansionTile(
                  title: "United States",
                  assetPath: 'assets/images/country_flags_svg/us.svg',
                  children: [
                    NavigationTile(text: "State List", onTap: () => BookListNavigation(context, BookListType.states),),
                    NavigationTile(text: "Analytics", onTap: () => AnalyticsNavigation(),),
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }

  void AnalyticsNavigation() {
    print("Analytics Navigation TODO");
  }

  void BookListNavigation(BuildContext context, BookListType bookListType) {
    print("Going to go to book list with type: $bookListType");
    Navigator.push(context,
      MaterialPageRoute( builder: (_) => BookList(bookListType: bookListType), ),
    );
  }

  Future<List<Book>> importBooks(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        return [];
      }

      final file = File(result.files.single.path!);
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);
      final books = (decoded as List)
          .map((item) => Book.fromJson(item))
          .toList();

      return books;
    } catch(e, st) {
      await showErrorDialog(context: context, body: "Failed to import book backup file");
      debugPrint("Error importing file er: ${e.toString()}");
      debugPrint("Error importing file st: ${st.toString()}");
      return [];
    }

  }

  Future<void> _sendEmail(BuildContext context, List<Book> data) async {
    try {
      String? recipient = "smr1292@gmail.com";//await showEmailAddressDialog(context: context);
      if((recipient ?? '').isEmpty) { return; }



      Directory? appDirectory = await getExternalStorageDirectory();
      debugPrint("Email App Directory PAth");
      debugPrint(appDirectory?.path);
      File? file = await _getBackupDataFile(context, appDirectory?.path ?? '', data);
      if(file == null) { return; }

      final Email email = Email(
        body: 'You are receiving this email because you backed-up data from your reading app',
        subject: 'Reading Locations Backup',
        recipients: [recipient ?? ''],
        cc: [],
        bcc: [],
        attachmentPaths: [file.path],
        isHTML: false,
      );
      try {
        await FlutterEmailSender.send(email);
        await showSuccessDialog(context: context, title: "Success", body: "${data.length} books backed-up successfully.");
      } catch (e) {
        debugPrint("_sendEmail send catch block");
        debugPrint(e.toString());
        showErrorDialog(context: context, body: "Unable to open email client. Make sure to set up an email client");
      }

    } catch (e) {
      debugPrint(e.toString());
      showErrorDialog(context: context, body: "Failed to send email");
    }

  }

  Future<File?> _getBackupDataFile(BuildContext context, String pathToTryFirst, List<Book> data) async {
    Directory? directory = Directory(pathToTryFirst);
    if (!await directory.exists()) directory = await getExternalStorageDirectory();
    if ((await directory?.exists() ?? false) == false) {
      showErrorDialog(context: context, body: "Unable to find directory to save file.");
      return null;
    }

    debugPrint('Got following path: ${directory?.path}' );
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    File file = File("${directory?.path}/book-list-backup-$formattedDate.json");
    await file.writeAsString(jsonEncode(data));
    return file;
  }
}
