import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProduct(String id);
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  // Mock data de tatuagens para simular um banco de dados
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'Dragão Oriental',
      'description':
          'Tatuagem de dragão tradicional japonês com cores vibrantes e detalhes precisos. Ideal para costas ou braço inteiro.',
      'price': 1200.00,
      'imageUrl':
          'https://w7.pngwing.com/pngs/265/490/png-transparent-easten-dragon-red-oriental-dragon-tattoo-thumbnail.png',
      'stock': 5,
      'category': 'Old School',
    },
    {
      'id': '2',
      'name': 'Pássaro New School',
      'description':
          'Tatuagem colorida em estilo New School de um beija-flor com elementos gráficos modernos.',
      'price': 850.00,
      'imageUrl':
          'https://st.depositphotos.com/1052445/4100/v/450/depositphotos_41003087-stock-illustration-swallow-and-rose-old-school.jpg',
      'stock': 3,
      'category': 'New School',
    },
    {
      'id': '3',
      'name': 'Padrão Maori',
      'description':
          'Desenho tribal inspirado na cultura Maori, com linhas precisas e simetria perfeita. Ideal para ombro ou antebraço.',
      'price': 780.00,
      'imageUrl':
          'https://img.lovepik.com/png/20231029/Maori-tribal-style-tattoo-pattern-black-sea-turtle-black-and_405507_wh860.png',
      'stock': 8,
      'category': 'Tribal',
    },
    {
      'id': '4',
      'name': 'Retrato Realista',
      'description':
          'Retrato hiperrealista com sombreamento detalhado. Perfeito para homenagear alguém especial.',
      'price': 1500.00,
      'imageUrl':
          'https://desenhosrealistas.com.br/wp-content/uploads/2018/08/tatuagem-realista.jpg',
      'stock': 2,
      'category': 'Realista',
    },
    {
      'id': '5',
      'name': 'Mandala Geométrica',
      'description':
          'Mandala com padrões geométricos precisos e simetria perfeita. Design minimalista com grande impacto visual.',
      'price': 650.00,
      'imageUrl':
          'https://static.vecteezy.com/ti/vetor-gratis/p1/9751732-contorno-geometrico-mandala-elemento-vetor.jpg',
      'stock': 10,
      'category': 'Geométrica',
    },
    {
      'id': '6',
      'name': 'Blackwork Floral',
      'description':
          'Composição floral em estilo blackwork com linhas bem definidas e contraste intenso.',
      'price': 700.00,
      'imageUrl':
          'https://www.dubuddha.org/wp-content/uploads/2017/05/Blackwork-Flowers-Tattoo-Sleeve-by-Jakob-Holst-Rasmussen.jpg',
      'stock': 6,
      'category': 'Blackwork',
    },
    {
      'id': '7',
      'name': 'Aquarela Abstrata',
      'description':
          'Composição colorida em estilo aquarela com respingos e gradientes suaves. Efeito único e personalizado.',
      'price': 950.00,
      'imageUrl':
          'https://img.freepik.com/fotos-premium/pintura-de-aquarela-abstrata-ondas-coloridas-e-vibrantes-cores-brilhantes-do-arco-iris-arte-fluida_14117-102861.jpg',
      'stock': 4,
      'category': 'Aquarela',
    },
    {
      'id': '8',
      'name': 'Linhas Minimalistas',
      'description':
          'Design minimalista com poucas linhas, elegante e discreto. Perfeito para pulso ou tornozelo.',
      'price': 350.00,
      'imageUrl':
          'https://i.pinimg.com/564x/15/78/6d/15786d30f21ee6b9e691edbbfada1675.jpg',
      'stock': 15,
      'category': 'Minimalista',
    },
    {
      'id': '9',
      'name': 'Rosa Old School',
      'description':
          'Clássica rosa no estilo tradicional americano com linhas grossas e cores vivas.',
      'price': 550.00,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRVkIMf0OIDAJY4y45SflZb-HuV3r1lfrRJDw&s',
      'stock': 7,
      'category': 'Old School',
    },
    {
      'id': '10',
      'name': 'Lobo Realista',
      'description':
          'Tatuagem hiperrealista de lobo com detalhes impressionantes nos pelos e expressão.',
      'price': 1350.00,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLF2EFlusTGAZ_ZqaEYQ4yXcADvnY3QptwJA&s',
      'stock': 3,
      'category': 'Realista',
    },
    {
      'id': '11',
      'name': 'Peixe Aquarela',
      'description':
          'Peixe koi em estilo aquarela com salpicos coloridos e traços leves.',
      'price': 880.00,
      'imageUrl':
          'https://i.pinimg.com/564x/a7/ff/0e/a7ff0eee947438b0289c544c87c64a0f.jpg',
      'stock': 5,
      'category': 'Aquarela',
    },
    {
      'id': '12',
      'name': 'Padrão Geométrico',
      'description':
          'Composição de formas geométricas com precisão matemática e equilíbrio perfeito.',
      'price': 750.00,
      'imageUrl':
          'https://blog.tattoo2me.com/wp-content/uploads/2023/06/IMG_1076.jpeg',
      'stock': 9,
      'category': 'Geométrica',
    },
    {
      'id': '13',
      'name': 'Carta de Baralho',
      'description':
          'Tatuagem de carta de baralho no estilo New School com cores vibrantes e contornos intensos.',
      'price': 600.00,
      'imageUrl':
          'https://i.pinimg.com/564x/39/66/f3/3966f3bcdfb9051e966b9851dee01983.jpg',
      'stock': 6,
      'category': 'New School',
    },
    {
      'id': '14',
      'name': 'Braceletes Tribais',
      'description':
          'Conjunto de linhas tribais formando um bracelete completo para o braço.',
      'price': 900.00,
      'imageUrl':
          'https://i.pinimg.com/564x/96/46/85/9646850b49afab7eb4f3c688a4b7033b.jpg',
      'stock': 4,
      'category': 'Tribal',
    },
    {
      'id': '15',
      'name': 'Blackwork Ornamental',
      'description':
          'Padrões ornamentais em blackwork com inspiração em arquitetura gótica e mandalas.',
      'price': 820.00,
      'imageUrl': 'https://cdntattoofilter.com/tattoo/393832/l.jpg',
      'stock': 5,
      'category': 'Blackwork',
    },
    {
      'id': '16',
      'name': 'Linha Fina Minimalista',
      'description':
          'Pequeno desenho com linhas finíssimas e detalhes delicados. Discreto e elegante.',
      'price': 300.00,
      'imageUrl':
          'https://psychodolltattoo.com/wp-content/uploads/2022/09/psycho-doll-tattoo-studio-mallorca5-TATUAJES-768x1592.jpg',
      'stock': 20,
      'category': 'Minimalista',
    },
  ];

  @override
  Future<List<ProductModel>> getProducts() async {
    // Simulando delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    return _products.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products
        .map((json) => ProductModel.fromJson(json))
        .firstWhere(
          (product) => product.id == id,
          orElse: () => throw Exception('Produto não encontrado'),
        );
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.add(product.toJson());
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _products.indexWhere((p) => p['id'] == product.id);
    if (index != -1) {
      _products[index] = product.toJson();
    } else {
      throw Exception('Produto não encontrado');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.removeWhere((product) => product['id'] == id);
  }
}
