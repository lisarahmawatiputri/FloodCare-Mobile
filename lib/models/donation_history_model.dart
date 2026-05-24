class DonationHistory {
  final int id;
  final int? programId;
  final String orderId;
  final String programTitle;
  final String programImage;
  final int amount;
  final String status;
  final String? snapToken;
  final String? snapUrl;
  final String createdAt;
  final String updatedAt;

  DonationHistory({
    required this.id,
    required this.programId,
    required this.orderId,
    required this.programTitle,
    required this.programImage,
    required this.amount,
    required this.status,
    required this.snapToken,
    required this.snapUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DonationHistory.fromJson(Map<String, dynamic> json) {
    final program = json['program'] ?? json['donation_program'];

    return DonationHistory(
      id: _parseInt(json['id']),
      programId: json['program_id'] == null
          ? null
          : _parseInt(json['program_id']),
      orderId: _parseString(
        json['order_id'] ??
            json['kode_transaksi'] ??
            json['midtrans_order_id'] ??
            json['transaction_id'],
      ),
      programTitle: _parseString(
        json['program_title'] ??
            json['nama_program'] ??
            json['judul_program'] ??
            json['title'] ??
            (program is Map ? program['nama_program'] : null) ??
            (program is Map ? program['title'] : null),
        fallback: 'Program Donasi',
      ),
      programImage: _parseString(
        json['program_image'] ??
            json['foto'] ??
            json['image'] ??
            json['gambar'] ??
            (program is Map ? program['foto'] : null) ??
            (program is Map ? program['image'] : null),
      ),
      amount: _parseInt(
        json['amount'] ??
            json['nominal'] ??
            json['jumlah_donasi'] ??
            json['total'],
      ),
      status: _parseString(
        json['status'] ??
            json['status_pembayaran'] ??
            json['payment_status'] ??
            json['transaction_status'],
        fallback: 'menunggu',
      ).toLowerCase(),
      snapToken: _parseNullableString(
        json['snap_token'] ?? json['snapToken'],
      ),
      snapUrl: _parseNullableString(
        json['snap_url'] ??
            json['snapUrl'] ??
            json['payment_url'] ??
            json['redirect_url'],
      ),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
    );
  }

  bool get canContinuePayment {
    final normalizedStatus = status.toLowerCase();

    final isPending = normalizedStatus == 'pending' ||
        normalizedStatus == 'menunggu' ||
        normalizedStatus == 'unpaid' ||
        normalizedStatus == 'belum_bayar';

    return isPending && snapUrl != null && snapUrl!.trim().isNotEmpty;
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'settlement':
      case 'capture':
      case 'paid':
      case 'success':
      case 'berhasil':
      case 'sukses':
        return 'Berhasil';

      case 'pending':
      case 'menunggu':
      case 'unpaid':
      case 'belum_bayar':
        return 'Menunggu Pembayaran';

      case 'expire':
      case 'expired':
      case 'kedaluwarsa':
        return 'Kedaluwarsa';

      case 'cancel':
      case 'cancelled':
      case 'canceled':
        return 'Dibatalkan';

      case 'deny':
      case 'failed':
      case 'failure':
      case 'gagal':
        return 'Gagal';

      default:
        return status.isEmpty ? 'Menunggu Pembayaran' : status;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.round();

    final text = value.toString().trim();

    if (text.isEmpty) return 0;

    final asInt = int.tryParse(text);
    if (asInt != null) return asInt;

    final asDouble = double.tryParse(text);
    if (asDouble != null) return asDouble.round();

    return 0;
  }

  static String _parseString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}