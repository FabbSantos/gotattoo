import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final Function() onDecrement;
  final Function() onIncrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Quantidade:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      quantity > 1
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: quantity > 1 ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                  onPressed: quantity > 1 ? onDecrement : null,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      quantity < maxQuantity
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: quantity < maxQuantity ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                  onPressed: quantity < maxQuantity ? onIncrement : null,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
