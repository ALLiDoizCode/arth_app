import 'package:arth_app/common/utils/snack_bar_utils.dart';
import 'package:arth_app/views/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/mint/mint_provider.dart';

class MintView extends ConsumerWidget {
  const MintView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minter = ref.watch(minterProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mint ckBTC"),
        actions: [
          if (minter.loading) ...[
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 230.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (minter.loading) ...[
                    const Center(child: Text("Fetching your bitcoin address...")),
                  ],
                  if (minter.btcAddress != null) ...[
                    const Text("1. Deposit Btc"),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: const [Text("Your bitcoin address")],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          minter.btcAddress ?? "----",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: minter.btcAddress!));
                            Snack.show(context, "Copied to clipboard");
                          },
                          icon: const Icon(Icons.copy),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: const [Text("Balance")],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 0.7.sw,
                          child: Text(
                            minter.bitcoinBalance.toString(),
                            maxLines: 3,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            Snack.show(context, "Refreshing...");
                            await ref.read(minterProvider.notifier).getBtcBalance();
                            Snack.show(context, "Refreshed");
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Deposit fee : ${minter.depositFee != null ? minter.depositFee! / BigInt.from(10).pow(8) : "--"} BTC",
                        ),
                      ],
                    )
                  ],
                ],
              ),
            ),
            if (ref.watch(minterProvider.notifier).canMint()) ...[
              SizedBox(
                height: 200.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("2. Mint ckBTC"),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CoolButton(
                          onTapDown: () => HapticFeedback.lightImpact(),
                          onTapUp: () {
                            showDialog(
                              context: context,
                              builder: (context) => Consumer(builder: (context, ref, child) {
                                final minter = ref.watch(minterProvider);
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!minter.loading && minter.result == null) ...[
                                        const Text("confirm Mint"),
                                      ],
                                      if (minter.error != null) ...[
                                        Text(
                                          minter.error ?? "Error",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Theme.of(context).colorScheme.error),
                                        ),
                                      ],
                                      if (minter.loading) ...[
                                         Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text("Minting..."),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (minter.result != null) ...[
                                        Text(minter.result.toString()),
                                      ]
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: minter.loading
                                          ? null
                                          : () {
                                              ref.read(minterProvider.notifier).updateBalance();
                                            },
                                      child: const Text("Mint"),
                                    ),
                                  ],
                                );
                              }),
                            );
                          },
                          child: Text(
                            "Mint",
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
