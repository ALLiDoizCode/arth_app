import 'package:agent_dart/agent_dart.dart';
import 'package:arth_app/common/enums/scan_type.dart';
import 'package:arth_app/common/utils/amount_utils.dart';
import 'package:arth_app/common/utils/snack_bar_utils.dart';
import 'package:arth_app/providers/unmint/unmint_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/buttons.dart';

final GlobalKey<FormState> unmintFormKey = GlobalKey<FormState>();

class UnMintView extends ConsumerWidget {
  const UnMintView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unmint = ref.watch(unmintProvider);
    final unmintN = ref.watch(unmintProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unmint ckBTC"),
        actions: [
          if (unmint.loading) ...[
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(),
              ),
            )
          ]
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("1.Your ckBTC deposit account"),
              SizedBox(
                height: 240.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (unmint.depositAccount != null) ...[
                      const SizedBox(height: 20),
                       Row(
                        children: const [Text("Owner")],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 0.7.sw,
                            child: Text(
                              unmint.depositAccount?.owner.toString() ?? "----",
                              maxLines: 3,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: unmint.depositAccount!.owner.toString()));
                              Snack.show(context, "Copied to clipboard");
                            },
                            icon: const Icon(Icons.copy, size: 18),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [Text("SubAccount")],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 0.7.sw,
                            child: Text(
                              unmint.depositAccount?.subaccount?.toHex() ?? "----",
                              maxLines: 3,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // print(unmint.depositAccount?.owner);
                              // print(unmint.depositAccount?.subaccount);
                              // print(unmint.depositAccount?.subaccount?.toHex());
                              // print(unmint.depositAccount?.subaccount?.toHex().toU8a());
                              Clipboard.setData(ClipboardData(text: unmint.depositAccount!.subaccount!.toHex()));
                              Snack.show(context, "Copied to clipboard");
                            },
                            icon: const Icon(Icons.copy, size: 18),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [Text("Account balance")],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 0.7.sw,
                            child: Text(
                              AmountUtils.divideBy10e8(amount: unmint.depositAccountBalance?.toInt() ?? 0).toString(),
                              maxLines: 3,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              Snack.show(context, "Refreshing...");
                              await ref.read(unmintProvider.notifier).balanceOfAccount(
                                    unmint.depositAccount!.owner,
                                    unmint.depositAccount!.subaccount,
                                  );
                              Snack.show(context, "Refreshed");
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                          )
                        ],
                      )
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 270.h,
                child: Form(
                  key: unmintFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text("2.Enter BTC address and amount to receive BTC"),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: unmintN.addressController,
                        decoration: InputDecoration(
                          hintText: "Enter Btc Address",
                          labelText: "Bitcoin Address",
                          suffixIcon: IconButton(
                            onPressed: () async {
                              String? a = await context.push("/scan", extra: ScanType.bitcoinAddress);
                              if (a != null) {
                                unmintN.setAddress(a);
                              }
                            },
                            icon: const Icon(Icons.qr_code),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (!unmintN.setAddress(value)) {
                            return 'Please enter valid address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: unmintN.amountController,
                        decoration: const InputDecoration(
                          hintText: "Enter Amount",
                          labelText: "Amount",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          try {
                            var a = double.parse(value);
                            if (a <= 0) {
                              return "Invalid amount";
                            }
                            return null;
                          } catch (e) {
                            return "Invalid amount";
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              unmintN.setAmount(unmint.depositAccountBalance!);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Max ${AmountUtils.divideBy10e8(amount: unmint.depositAccountBalance?.toInt() ?? 0).toString()}",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CoolButton(
                            onTapUp: () {
                              if (unmintN.validateAddressAndAmount() && unmintFormKey.currentState!.validate()) {
                                ref.read(unmintProvider.notifier).retriveBtc();
                              } else {
                                Snack.show(context, "Please enter valid address and amount");
                              }
                            },
                            child: Text(
                              "Receive Bitcoin",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
