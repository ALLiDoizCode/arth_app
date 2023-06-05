import 'package:agent_dart/agent_dart.dart';
import 'package:arth_app/common/enums/scan_type.dart';
import 'package:arth_app/common/enums/states.dart';
import 'package:arth_app/common/utils/amount_utils.dart';
import 'package:arth_app/providers/ckbtc_provider/ckbtc_provider.dart';
import 'package:arth_app/services/payid/payid_service.dart';
import 'package:arth_app/views/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/send_provider/send_provider.dart';

final GlobalKey<FormState> sendFormKey = GlobalKey<FormState>();

class SendView extends ConsumerWidget {
  const SendView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendProvider);
    final sendN = ref.read(sendProvider.notifier);
    final ckbtc = ref.read(ckBtcProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: sendFormKey,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: sendN.addressController,
                decoration: InputDecoration(
                  labelText: "PayId",
                  suffixIcon: IconButton(
                    onPressed: () async {
                      String? p = await context.push("/scan", extra: ScanType.principal);
                      if (p != null) {
                        ref.read(sendProvider.notifier).setAddress(p);
                      }
                    },
                    icon: const Icon(Icons.qr_code),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) {
                  ref.read(sendProvider.notifier).setAddress(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an address";
                  }
                  if (!sendN.isValidPrincipal()) {
                    return "Please enter a valid address";
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (sendN.isValidPrincipal()) ...[
                    InkWell(
                      onTap: () {
                        ref.read(sendProvider.notifier).toggleSubAccount();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(send.subaccountToo ? "Remove Subaccount" : "Add subaccount"),
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 16),
              if (send.subaccountToo) ...[
                TextFormField(
                  controller: sendN.subaccountController,
                  decoration: InputDecoration(
                    labelText: "SubAccount",
                    suffixIcon: IconButton(
                      onPressed: () async {
                        String? a = await context.push("/scan", extra: ScanType.accountID);
                        if (a != null) {
                          ref.read(sendProvider.notifier).setSubaccount(a);
                        }
                      },
                      icon: const Icon(Icons.qr_code),
                    ),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    ref.read(sendProvider.notifier).setSubaccount(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter an Account ID";
                    }
                    if (!ref.read(sendProvider.notifier).setSubaccount(value)) {
                      return "Please enter a valid Account ID";
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: sendN.amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                ),
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(sendProvider.notifier).setAmount(amount: ckbtc.balance, fee: ckbtc.fee);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text("Max ${ckbtc.balanceString}"),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox(height: 100)),
              CoolButton(
                onTapUp: /*sendN.isValid()
                    ?*/ () {
                        PayIdService().fetchAddresses("AlliDoizCode\$awesome.com","icp","mainnet");
                       /* print(result.first.addressDetails.address);
                        print(result.first.environment);
                        print(result.first.paymentNetwork);*/
                        /*bool valid = sendFormKey.currentState?.validate() ?? false;
                        if (valid) {
                          showSendDialog(context);
                        }*/
                      }
                    /*: null*/,
                child: Text(
                  "Send",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  showSendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          final send = ref.watch(sendProvider);
          final ckBtc = ref.watch(ckBtcProvider);
          return AlertDialog(
            title: const Text("Confirm"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (send.sendState == LoadingState.initial) ...[
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "Amount : ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(
                        text: AmountUtils.divideBy10e8(amount: send.amount!.toInt()).toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      const TextSpan(text: "\n"),
                      TextSpan(
                        text: "\nPrincipal: ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(
                        text: send.account!.owner.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      if (send.subaccountToo) ...[
                        const TextSpan(text: "\n"),
                        TextSpan(
                          text: "\nAccount: ",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextSpan(
                          text: send.account!.subaccount!.toHex(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                        const TextSpan(text: "\n"),
                      ],
                      TextSpan(
                        text: "\n\nFee: ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(
                        text: ((ckBtc.fee?.toInt() ?? 10) / 100000000).toStringAsFixed(8),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ]),
                  ),
                ],
                if (send.sendState == LoadingState.loading) ...[
                  const CircularProgressIndicator(),
                ],
                if (send.sendState == LoadingState.success) ...[
                  const Icon(Icons.check, color: Colors.green),
                  const Text("Success"),
                ],
                if (send.sendState == LoadingState.error) ...[
                  const Icon(Icons.error, color: Colors.red),
                  Text(send.result?.err.toString() ?? "Error"),
                ],
              ],
            ),
            actions: [
              if (send.sendState == LoadingState.initial) ...[
                CoolButton(
                  width: 0.3,
                  onTapUp: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "cancel",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                CoolButton(
                  width: 0.3,
                  onTapUp: () {
                    ref.read(sendProvider.notifier).send(ckBtc.fee ?? BigInt.from(10));
                  },
                  child: Text(
                    "send",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                )
              ],
              if (send.sendState == LoadingState.success || send.sendState == LoadingState.error) ...[
                CoolButton(
                  width: 0.3,
                  onTapUp: () {
                    ref.read(ckBtcProvider.notifier).getBalance();
                    context.pop();
                    context.pop();
                  },
                  child: Text(
                    "Ok",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                )
              ]
            ],
          );
        });
      },
    );
  }
}
