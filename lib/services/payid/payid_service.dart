import 'dart:convert';

import 'package:arth_app/models/address.dart';
import 'package:http/http.dart' as http;

class PayIdService {
  Future<List<Address>> fetchAddresses(String value,String ledger, String network) async {
    Map<String, String> headers = {
      "Accept" : "application/$ledger-$network+json"
    };
    List<Address> addressList = [];
    final payString = value.split("\$");
    var url = Uri.parse('https://qbu4y-iaaaa-aaaan-qdvda-cai.raw.icp0.io/${payString.first}');
    var response = await http.get(url, headers: headers);
    //print(response.body);
    List<dynamic> data = json.decode(response.body)["addresses"];
    for(var obj in data) {
      Address address = Address.fromJson(obj);
      addressList.add(address);
    }
    return addressList;
  }
}