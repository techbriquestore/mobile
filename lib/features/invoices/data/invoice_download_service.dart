import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceDownloadService {
  final Dio _dio;
  final String _baseUrl;

  InvoiceDownloadService(this._dio, this._baseUrl);

  /// Télécharge et ouvre la facture d'une commande.
  Future<void> downloadAndOpenOrderInvoice(String orderId) async {
    if (kIsWeb) {
      // Sur web, utiliser l'approche URL avec token (temporaire)
      await _downloadAndOpenOrderInvoiceWeb(orderId);
    } else {
      // Sur mobile, télécharger avec Dio et ouvrir nativement
      await _downloadAndOpenOrderInvoiceMobile(orderId);
    }
  }

  /// Télécharge et ouvre la facture d'une échéance.
  Future<void> downloadAndOpenScheduleInvoice(String scheduleId) async {
    if (kIsWeb) {
      await _downloadAndOpenScheduleInvoiceWeb(scheduleId);
    } else {
      await _downloadAndOpenScheduleInvoiceMobile(scheduleId);
    }
  }

  /// Télécharge et partage la facture d'une commande.
  Future<void> downloadAndShareOrderInvoice(String orderId) async {
    if (kIsWeb) {
      throw Exception('Le partage n\'est pas supporté sur web');
    }
    final file = await _downloadOrderInvoice(orderId);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Facture BRIQUES.STORE',
    );
  }

  /// Télécharge et partage la facture d'une échéance.
  Future<void> downloadAndShareScheduleInvoice(String scheduleId) async {
    if (kIsWeb) {
      throw Exception('Le partage n\'est pas supporté sur web');
    }
    final file = await _downloadScheduleInvoice(scheduleId);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Facture BRIQUES.STORE',
    );
  }

  // === Mobile implementation ===

  Future<void> _downloadAndOpenOrderInvoiceMobile(String orderId) async {
    final file = await _downloadOrderInvoice(orderId);
    final result = await OpenFilex.open(file.path, type: 'application/pdf');
    if (result.type != ResultType.done) {
      throw Exception('Impossible d\'ouvrir le fichier PDF');
    }
  }

  Future<void> _downloadAndOpenScheduleInvoiceMobile(String scheduleId) async {
    final file = await _downloadScheduleInvoice(scheduleId);
    final result = await OpenFilex.open(file.path, type: 'application/pdf');
    if (result.type != ResultType.done) {
      throw Exception('Impossible d\'ouvrir le fichier PDF');
    }
  }

  Future<File> _downloadOrderInvoice(String orderId) async {
    final dir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory('${dir.path}/invoices');
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    final filePath = '${invoicesDir.path}/facture_$orderId.pdf';
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    }

    final response = await _dio.get<List<int>>(
      '/invoices/order/$orderId/download',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'application/pdf'},
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Téléchargement impossible (HTTP ${response.statusCode})');
    }

    await file.writeAsBytes(response.data!);
    return file;
  }

  Future<File> _downloadScheduleInvoice(String scheduleId) async {
    final dir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory('${dir.path}/invoices');
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    final filePath = '${invoicesDir.path}/facture_echeance_$scheduleId.pdf';
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    }

    final response = await _dio.get<List<int>>(
      '/invoices/schedule/$scheduleId/download',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'application/pdf'},
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Téléchargement impossible (HTTP ${response.statusCode})');
    }

    await file.writeAsBytes(response.data!);
    return file;
  }

  // === Web implementation (fallback avec token en URL) ===

  Future<void> _downloadAndOpenOrderInvoiceWeb(String orderId) async {
    // Récupérer le token depuis le header Authorization (stocké dans Dio)
    // Note: c'est une solution temporaire pour web uniquement
    throw Exception('Veuillez utiliser un appareil mobile pour télécharger les factures');
  }

  Future<void> _downloadAndOpenScheduleInvoiceWeb(String scheduleId) async {
    throw Exception('Veuillez utiliser un appareil mobile pour télécharger les factures');
  }
}
