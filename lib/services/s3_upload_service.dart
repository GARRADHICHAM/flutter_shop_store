import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class S3UploadService {
  // Replace these with your actual AWS credentials
  static const String _accessKey = 'AKIA3TUQFRVTWK3V6DRF';
  static const String _secretKey = 'Setw6aRKD9fvMF7P+lBwWtn3KmC3leCrrCM2k72i';
  static const String _region = 'eu-north-1'; // e.g., 'eu-west-1'
  static const String _bucket = 'clothign-imgs-bucket';

  static Future<String> uploadProductImage(Uint8List bytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final key = 'products/$fileName';

    final now = DateTime.now().toUtc();
    final dateStamp = [
      now.year.toString(),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
    ].join();
    final amzDate = '${dateStamp}T'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}Z';

    final host = '$_bucket.s3.$_region.amazonaws.com';
    final payloadHash = sha256.convert(bytes).toString();

    // Canonical headers (sorted alphabetically)
    final canonicalHeaders =
        'host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';
    const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';

    final canonicalRequest = [
      'PUT',
      '/$key',
      '', // no query string
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final credentialScope = '$dateStamp/$_region/s3/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    // Derive signing key
    List<int> hmac(List<int> key, String data) =>
        Hmac(sha256, key).convert(utf8.encode(data)).bytes;

    final signingKey = hmac(
      hmac(
        hmac(
          hmac(utf8.encode('AWS4$_secretKey'), dateStamp),
          _region,
        ),
        's3',
      ),
      'aws4_request',
    );

    final signature =
        Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    final authorization = 'AWS4-HMAC-SHA256 '
        'Credential=$_accessKey/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    final url = 'https://$host/$key';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': authorization,
        'Content-Type': 'image/jpeg',
        'x-amz-content-sha256': payloadHash,
        'x-amz-date': amzDate,
        'Host': host,
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'S3 upload failed: ${response.statusCode}\n${response.body}');
    }

    return url;
  }
}
