// your google auth credentials

class MyCredentials {
  // your google auth credentials
  final _credentials = r'''
    {
      "type": ,
      "project_id": ,
      "private_key_id":,
      "private_key": ,
      "client_email": ,
      "client_id": ,
      "auth_uri": ,
      "token_uri": ,
      "auth_provider_x509_cert_url": ,
      "client_x509_cert_url": 
    }
    ''';

  // your spreadsheet id
  final _spreadsheetId = "";

  String getCredentials() {
    return _credentials;
  }

  String getSpreadSheetId() {
    return _spreadsheetId;
  }
}
