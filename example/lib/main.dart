import 'package:example/app_localizations.dart';
import 'package:example/data.dart';
import 'package:flutter/material.dart';
import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      builder: (context, child) {
        // Add AccessibilityTools to the widget tree. The tools are available
        // only in debug mode
        return AccessibilityTools(
          checkFontOverflows: true,
          child: child,
        );
      },
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        cardTheme: CardTheme(
          color: Colors.blue.withOpacity(.1),
        ),
      ),
      home: const MyHomePage(),
      localizationsDelegates: [
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fi', 'FI'),
        Locale('en', 'US'),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _shoppingCart = <PurchaseableItem, int>{};
  final _selectedProductTypes = <ProductType>[...ProductType.values];
  bool? _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.shopName),
        centerTitle: true,
        actions: [
          // This icon is problematic to use:
          // * icon's click area is too small
          // * no label, impossible to know what this icon is for when using a
          //   screen reader
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {},
              child: const Icon(Icons.person, size: 24),
            ),
          )
        ],
      ),
      body: ListView(
        padding: MediaQuery.paddingOf(context).copyWith(top: 0) +
            const EdgeInsets.all(16),
        children: <Widget>[
          SizedBox(
            // Fixed height with a text inside may cause overflow or text may
            // be clipped. This issue is visible when the font size is increased
            // in the device settings
            height: 48,
            child: Text(
              strings.greetings,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ProductType.values.map((e) {
              return ChoiceChip(
                label: Text(e.name),
                selected: _selectedProductTypes.contains(e),
                onSelected: (isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedProductTypes.add(e);
                    } else {
                      _selectedProductTypes.remove(e);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          ...purchaseableItems(_selectedProductTypes).map((e) {
            final quantity = _shoppingCart[e] ?? 0;
            return ProductListItem(
              item: e,
              quantity: quantity,
              onQuantityChanged: (quantity) {
                setState(() {
                  if (quantity == 0) {
                    _shoppingCart.remove(e);
                  } else {
                    _shoppingCart[e] = quantity;
                  }
                });
              },
            );
          }),
          const SizedBox(height: 24),
          // This button has no label or text. It's impossible to know what
          // this button is for when using a screen reader. It's also impossible
          // to tell what icon this is since it's also not labeled
          ElevatedButton(
            onPressed: () {},
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.shopping_cart,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.signInTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                // Semantics of this sign in form is broken: it's impossible to tell
                // what the fields are for because they are not labeled using
                // TextField's decoration
                const SizedBox(height: 12),
                Text(strings.email),
                const TextField(),
                const SizedBox(height: 12),
                Text(strings.password),
                const TextField(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // This checkbox is not attached to the following text so
                    // screen readers don't know about what this checkbox is for
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value);
                      },
                    ),
                    // This text is not wrapped in Expanded or Flexible so it
                    // may overflow when the font size is increased in
                    // the device settings
                    const Text('Remember me'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  const ProductListItem({
    required this.item,
    required this.quantity,
    required this.onQuantityChanged,
    super.key,
  });

  final PurchaseableItem item;
  final int quantity;
  final void Function(int quantity) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(item.localizedName(AppLocalizations.of(context))),
        const Spacer(),
        Text(
          item.formattedPrice(AppLocalizations.of(context).locale),
          style: TextStyle(
            // Highlighting the sale price with color doesn't work in all cases.
            // For example, people with protanopia may not see the difference
            // between the regular price and the red-colored sale price
            color: item.isOnSale ? const Color.fromARGB(255, 202, 0, 0) : null,
          ),
        ),
        const SizedBox(width: 8),
        QuantitySelector(
          quantity: quantity,
          onQuantityChanged: onQuantityChanged,
        ),
      ],
    );
  }
}

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
  }) : assert(quantity >= 0);

  final int quantity;
  final void Function(int quantity) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    // Increase/decrease buttons are not labeled so screen readers don't know
    // what they are for. Quantity could be challenging to understand for some
    // users
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => _updateQuantity(quantity - 1),
        ),
        const SizedBox(width: 2),
        Text(quantity.toString()),
        const SizedBox(width: 2),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _updateQuantity(quantity + 1),
        ),
      ],
    );
  }

  void _updateQuantity(int newQuantity) {
    final quantity = newQuantity.clamp(0, 100);
    onQuantityChanged(quantity);
  }
}
