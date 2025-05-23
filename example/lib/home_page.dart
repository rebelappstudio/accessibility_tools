import 'package:example/app_localizations.dart';
import 'package:example/data.dart';
import 'package:flutter/material.dart';

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

    final density = Theme.of(context).visualDensity;
    final baseInset = switch (density) {
      VisualDensity.comfortable => 18.0,
      VisualDensity.compact => 6.0,
      VisualDensity.standard => 12.0,
      _ => 12.0,
    };

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
            padding: EdgeInsets.all(baseInset),
            child: InkWell(
              onTap: () {},
              child: const Icon(Icons.person, size: 24),
            ),
          ),
        ],
      ),
      body: ListView(
        padding:
            MediaQuery.paddingOf(context).copyWith(top: 0) +
            EdgeInsets.all(baseInset * 2),
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
          SizedBox(height: baseInset),
          Theme(
            data: ThemeData(
              // This chip theme is not very accessible: users with deuteranopia
              // might have problems recognizing which item is selected
              chipTheme: ChipThemeData(
                backgroundColor: const Color(0xFFF44535).withValues(alpha: 0.6),
                selectedColor: const Color(0xFF8BC549).withValues(alpha: 0.6),
                showCheckmark: false,
                side: BorderSide.none,
              ),
            ),
            child: Wrap(
              spacing: baseInset,
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
          ),
          SizedBox(height: baseInset),
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
          SizedBox(height: baseInset * 2),
          // This button has no label or text. It's impossible to know what
          // this button is for when using a screen reader. It's also impossible
          // to tell what icon this is since it's also not labeled
          ElevatedButton(
            onPressed: () {},
            child: Padding(
              padding: EdgeInsets.all(baseInset),
              child: const Icon(Icons.shopping_cart, size: 42),
            ),
          ),
          SizedBox(height: baseInset * 2),
          // This banner image is not accessible: there's no label that explains
          // what this image contains. It's impossible to understand the content
          // for screen reader users
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Card(child: Image.asset('assets/banner.png')),
          ),
          SizedBox(height: baseInset * 2),
          Card(
            child: Padding(
              padding: EdgeInsets.all(baseInset * 3),
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
                  SizedBox(height: baseInset),
                  Text(strings.email),
                  const TextField(),
                  SizedBox(height: baseInset),
                  Text(strings.password),
                  const TextField(),
                  SizedBox(height: baseInset),
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
                      Text(strings.rememberMe),
                    ],
                  ),
                ],
              ),
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
        Text(
          item.localizedName(AppLocalizations.of(context)),
          style: const TextStyle(fontSize: 18),
        ),
        const Spacer(),
        Text(
          item.formattedPrice(AppLocalizations.of(context).locale),
          style: TextStyle(
            // Highlighting the sale price with color doesn't work in all cases.
            // For example, people with protanopia may not see the difference
            // between the regular price and the red-colored sale price
            fontSize: 18,
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
        Text(
          quantity.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: quantity > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
