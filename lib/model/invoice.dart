// ignore_for_file: equal_keys_in_map

import 'dart:convert';

class Invoice {
  String? invoiceNumber;
  String? vaNumber;
  int? eventId;
  int? amount;
  int? status;
  int? paymentMethodId;
  String? bank;
  String? eventName;
  String? companyName;
  String? picName;
  String? picEmail;
  String? peserta;
  int? jumlahPeserta;
  String? errorMessage;
  dynamic items;
  String? statusDescription;
  String? paymentDate;
  String? paymentChannelDesc;

  Invoice({
    this.invoiceNumber,
    this.vaNumber,
    this.eventId,
    this.amount,
    this.status,
    this.statusDescription,
    this.paymentMethodId,
    this.bank,
    this.eventName,
    this.companyName,
    this.picEmail,
    this.picName,
    this.peserta,
    this.jumlahPeserta,
    this.errorMessage,
    this.items,
    this.paymentDate,
    this.paymentChannelDesc
  });

  factory Invoice.fromMap(Map<String, dynamic> data) => Invoice(
        invoiceNumber: data['invoice_number'] ?? "",
        bank: data['bank'] ?? "",
        vaNumber: data['va_no'] ?? "",
        eventId: data['event_id'] ?? 0,
        amount: data['amount'] ?? 0,
        status: data['status'] ?? 0,
        statusDescription: data['status_desc'] ?? "",
        paymentDate: data['payment_date'] ?? "",
        paymentChannelDesc: data['payment_channel_desc'] ?? "",
        jumlahPeserta: data['jumlah_peserta'] ?? 0,
        eventName: data['event_name'] ?? "",
        errorMessage: data['error_message'] ?? "",
        companyName: data['company_name'] ?? "",
        picEmail: data['pic_email'] ?? "",
        picName: data['pic_name'] ?? "",
        peserta: data['peserta'] ?? "",
        paymentMethodId: data['payment_method_id'] ?? 0,
        items: data['items']?? null
      );

  Map<String, dynamic> toMap() => {
        'invoice_number': invoiceNumber,
        'va_no': vaNumber,
        'event_id': eventId,
        'amount': amount,
        'status': status,
        'payment_method_id': paymentMethodId,
        'jumlah_peserta': jumlahPeserta,
        'bank': bank,
        'event_name': eventName,
        'peserta': peserta,
        'company_name': companyName,
        'pic_name': picName,
        'pic_email': picName,
        'items': items,
        'payment_date': paymentDate,
        'payment_channel_desc': paymentChannelDesc,
        'status_desc': statusDescription,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Invoice].
  factory Invoice.fromJson(String data) {
    return Invoice.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Invoice] to a JSON string.
  String toJson() => json.encode(toMap());
}
