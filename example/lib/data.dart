import 'package:example/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ProductType { fruit, vegetable }

enum ProductId {
  cucumber,
  tomato,
  apple,
  banana,
  pineapple,
  orange,
  grapes,
  watermelon,
  strawberry,
  mango,
  peach,
  pear,
  lemon,
  blueberry,
  raspberry,
}

class PurchaseableItem {
  final ProductId id;
  final int priceCents;
  final ProductType type;
  final bool isOnSale;

  const PurchaseableItem({
    required this.id,
    required this.priceCents,
    required this.type,
    required this.isOnSale,
  });

  String formattedPrice(Locale locale) {
    return NumberFormat.currency(
      locale: locale.languageCode,
      symbol: '\$',
    ).format(priceCents / 100);
  }

  @override
  String toString() =>
      'PurchaseableItem(name: $id, priceCents: $priceCents, type: $type)';

  @override
  bool operator ==(covariant PurchaseableItem other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.priceCents == priceCents &&
        other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ priceCents.hashCode ^ type.hashCode;

  String localizedName(AppLocalizations strings) {
    return switch (id) {
      ProductId.cucumber => strings.productNameCucumber,
      ProductId.tomato => strings.productNameTomato,
      ProductId.apple => strings.productNameApple,
      ProductId.banana => strings.productNameBanana,
      ProductId.pineapple => strings.productNamePineapple,
      ProductId.orange => strings.productNameOrange,
      ProductId.grapes => strings.productNameGrapes,
      ProductId.watermelon => strings.productNameWatermelon,
      ProductId.strawberry => strings.productNameStrawberry,
      ProductId.mango => strings.productNameMango,
      ProductId.peach => strings.productNamePeach,
      ProductId.pear => strings.productNamePear,
      ProductId.lemon => strings.productNameLemon,
      ProductId.blueberry => strings.productNameBlueberry,
      ProductId.raspberry => strings.productNameRaspberry,
    };
  }
}

List<PurchaseableItem> purchaseableItems(List<ProductType> types) {
  return const [
    PurchaseableItem(
      id: ProductId.cucumber,
      priceCents: 100,
      type: ProductType.vegetable,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.tomato,
      priceCents: 150,
      type: ProductType.vegetable,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.apple,
      priceCents: 175,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.banana,
      priceCents: 400,
      type: ProductType.fruit,
      isOnSale: true,
    ),
    PurchaseableItem(
      id: ProductId.pineapple,
      priceCents: 600,
      type: ProductType.fruit,
      isOnSale: true,
    ),
    PurchaseableItem(
      id: ProductId.orange,
      priceCents: 250,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.grapes,
      priceCents: 300,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.watermelon,
      priceCents: 800,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.strawberry,
      priceCents: 200,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.mango,
      priceCents: 450,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.peach,
      priceCents: 350,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.pear,
      priceCents: 300,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.lemon,
      priceCents: 150,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.blueberry,
      priceCents: 250,
      type: ProductType.fruit,
      isOnSale: false,
    ),
    PurchaseableItem(
      id: ProductId.raspberry,
      priceCents: 400,
      type: ProductType.fruit,
      isOnSale: true,
    ),
  ].where((element) => types.contains(element.type)).toList();
}
