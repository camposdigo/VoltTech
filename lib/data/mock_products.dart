import 'package:flutter/material.dart';
import '../models/product.dart';

const mockProducts = <Product>[
  Product(id: 'smartphone-pro-x', name: 'Smartphone Pro X', category: 'Smartphones', price: 3999, oldPrice: 4599, discount: 13, icon: Icons.smartphone_rounded, description: 'Smartphone premium com tela OLED, câmera avançada e alto desempenho para uso diário.', rating: 4.8, stock: 12),
  Product(id: 'notebook-ultra', name: 'Notebook Ultra', category: 'Notebooks', price: 5499, oldPrice: 6299, discount: 12, icon: Icons.laptop_mac_rounded, description: 'Notebook leve e potente para estudos, trabalho, programação e produtividade.', rating: 4.7, stock: 7),
  Product(id: 'headphone-air-max', name: 'Headphone Air Max', category: 'Áudio', price: 899, oldPrice: 1099, discount: 18, icon: Icons.headphones_rounded, description: 'Headphone sem fio com cancelamento de ruído, graves intensos e bateria de longa duração.', rating: 4.9, stock: 22),
  Product(id: 'speaker-volt-boom', name: 'Caixa de Som Volt Boom', category: 'Áudio', price: 699, oldPrice: 849, discount: 18, icon: Icons.speaker_rounded, description: 'Caixa de som Bluetooth portátil com som 360°, resistência a respingos e até 18 horas de bateria.', rating: 4.9, stock: 16),
  Product(id: 'smartwatch-vision', name: 'Smartwatch Vision', category: 'Smartwatches', price: 1299, oldPrice: 1599, discount: 19, icon: Icons.watch_rounded, description: 'Smartwatch com monitoramento de atividades, notificações e tela AMOLED.', rating: 4.6, stock: 11),
  Product(id: 'camera-vision-4k', name: 'Câmera Vision 4K', category: 'Câmeras', price: 2799, oldPrice: 3199, discount: 12, icon: Icons.photo_camera_rounded, description: 'Câmera compacta 4K para fotos e vídeos com estabilização digital e conectividade sem fio.', rating: 4.5, stock: 5),
  Product(id: 'carregador-turbo-65w', name: 'Carregador Turbo 65W', category: 'Acessórios', price: 199, oldPrice: 249, discount: 20, icon: Icons.bolt_rounded, description: 'Carregador compacto de 65W com USB-C e carregamento rápido para múltiplos dispositivos.', rating: 4.8, stock: 35),
  Product(id: 'mouse-pro-wireless', name: 'Mouse Pro Wireless', category: 'Acessórios', price: 349, oldPrice: 429, discount: 18, icon: Icons.mouse_rounded, description: 'Mouse sem fio ergonômico com alta precisão e bateria recarregável.', rating: 4.7, stock: 28),
];

const mockCategories = <String>['Todos', 'Smartphones', 'Notebooks', 'Áudio', 'Câmeras', 'Smartwatches', 'Acessórios'];
