import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  static Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String text = recognizedText.text;
      return text;
    } catch (e) {
      print('Error recognizing text: $e');
      return '';
    }
  }

  static Future<List<String>> extractWords(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      List<String> words = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            words.add(element.text);
          }
        }
      }
      
      return words;
    } catch (e) {
      print('Error extracting words: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> recognizeTextWithDetails(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      List<Map<String, dynamic>> blocks = [];
      
      for (TextBlock block in recognizedText.blocks) {
        Map<String, dynamic> blockData = {
          'text': block.text,
          'lines': [],
          'boundingBox': {
            'left': block.boundingBox.left,
            'top': block.boundingBox.top,
            'right': block.boundingBox.right,
            'bottom': block.boundingBox.bottom,
          },
        };
        
        for (TextLine line in block.lines) {
          blockData['lines'].add({
            'text': line.text,
            'confidence': line.confidence,
          });
        }
        
        blocks.add(blockData);
      }
      
      return {
        'fullText': recognizedText.text,
        'blocks': blocks,
      };
    } catch (e) {
      print('Error recognizing text with details: $e');
      return {'fullText': '', 'blocks': []};
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}

// Basic ML Service for image classification and smart categorization
class MlService {
  // Detectar y extraer el nombre del producto de la imagen
  static Future<Map<String, dynamic>> analyzeProductImage(File imageFile) async {
    try {
      // 1. Extraer texto de la imagen con OCR
      final text = await OcrService.recognizeText(imageFile);
      final words = await OcrService.extractWords(imageFile);
      
      // 2. Identificar el nombre del producto (primeras palabras importantes)
      String productName = _extractProductName(text, words);
      
      // 3. Sugerir categoría basada en el nombre/palabras clave
      String suggestedCategory = _suggestCategoryFromText(text, words);
      
      return {
        'productName': productName,
        'suggestedCategory': suggestedCategory,
        'extractedText': text,
        'confidence': text.isNotEmpty ? 'high' : 'low',
      };
    } catch (e) {
      print('Error analyzing product image: $e');
      return {
        'productName': '',
        'suggestedCategory': 'General',
        'extractedText': '',
        'confidence': 'low',
      };
    }
  }

  static String _extractProductName(String fullText, List<String> words) {
    if (words.isEmpty) return '';
    
    // Filtrar palabras cortas o números solos
    final meaningfulWords = words.where((word) => 
      word.length > 2 && 
      !_isOnlyNumbers(word) &&
      !_isCommonWord(word)
    ).toList();
    
    if (meaningfulWords.isEmpty) {
      // Si no hay palabras significativas, usar las primeras 2-3 palabras
      return words.take(3).join(' ');
    }
    
    // Tomar las primeras 2-3 palabras significativas como nombre del producto
    return meaningfulWords.take(3).join(' ');
  }

  static bool _isOnlyNumbers(String word) {
    return RegExp(r'^\d+$').hasMatch(word);
  }

  static bool _isCommonWord(String word) {
    final commonWords = ['de', 'la', 'el', 'los', 'las', 'un', 'una', 'y', 'o', 'con'];
    return commonWords.contains(word.toLowerCase());
  }

  static String _suggestCategoryFromText(String text, List<String> words) {
    final textLower = text.toLowerCase();
    final wordsLower = words.map((w) => w.toLowerCase()).toList();
    
    // Base de conocimiento de categorías
    final categoryKeywords = {
      'Alimentos': ['comida', 'alimento', 'cereal', 'arroz', 'pasta', 'galleta', 'pan', 'leche', 'yogurt', 'queso', 'carne', 'pollo', 'pescado', 'fruta', 'verdura', 'snack', 'dulce', 'chocolate', 'refresco', 'jugo', 'bebida', 'agua', 'café', 'té'],
      'Bebidas': ['bebida', 'refresco', 'jugo', 'agua', 'café', 'té', 'gaseosa', 'soda', 'vino', 'cerveza', 'licor', 'energética'],
      'Limpieza': ['limpieza', 'detergente', 'jabón', 'cloro', 'desinfectante', 'shampoo', 'limpiador', 'esponja', 'trapo', 'escoba', 'trapeador'],
      'Higiene': ['higiene', 'shampoo', 'jabón', 'pasta', 'dental', 'cepillo', 'desodorante', 'perfume', 'crema', 'toalla', 'papel', 'higiénico', 'pañal'],
      'Electrónica': ['electrónica', 'cable', 'cargador', 'batería', 'auricular', 'mouse', 'teclado', 'monitor', 'laptop', 'tablet', 'celular', 'teléfono', 'computadora', 'usb'],
      'Herramientas': ['herramienta', 'martillo', 'destornillador', 'llave', 'tornillo', 'clavo', 'sierra', 'taladro', 'pinza', 'alicate'],
      'Oficina': ['oficina', 'papel', 'lapicero', 'lápiz', 'cuaderno', 'folder', 'archivador', 'grapadora', 'clips', 'marcador', 'resaltador', 'borrador'],
      'Ropa': ['ropa', 'camisa', 'pantalón', 'vestido', 'zapato', 'calcetín', 'medias', 'chaqueta', 'abrigo', 'falda', 'blusa', 'playera', 'suéter'],
      'Hogar': ['hogar', 'mueble', 'silla', 'mesa', 'lámpara', 'cortina', 'alfombra', 'almohada', 'sábana', 'cobija', 'toalla', 'plato', 'vaso', 'taza', 'olla', 'sartén'],
      'Juguetes': ['juguete', 'muñeca', 'carro', 'pelota', 'juego', 'rompecabezas', 'lego', 'puzzle', 'peluche'],
      'Deportes': ['deporte', 'pelota', 'balón', 'raqueta', 'bicicleta', 'patines', 'gimnasio', 'pesas', 'colchoneta'],
      'Mascotas': ['mascota', 'perro', 'gato', 'alimento', 'comida', 'juguete', 'collar', 'correa', 'cama'],
    };
    
    // Buscar coincidencias de palabras clave
    Map<String, int> categoryScores = {};
    
    for (var entry in categoryKeywords.entries) {
      int score = 0;
      for (var keyword in entry.value) {
        if (textLower.contains(keyword)) {
          score += 10;
        }
        if (wordsLower.any((word) => word.contains(keyword) || keyword.contains(word))) {
          score += 5;
        }
      }
      if (score > 0) {
        categoryScores[entry.key] = score;
      }
    }
    
    // Retornar la categoría con mayor puntaje
    if (categoryScores.isEmpty) {
      return 'General';
    }
    
    var sortedEntries = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedEntries.isEmpty) {
      return 'General';
    }
    
    return sortedEntries.first.key;
  }

  // This would integrate TensorFlow Lite for object recognition
  static Future<String> classifyImage(File imageFile) async {
    // TODO: Implement TFLite model for object classification
    // For now, return a placeholder
    return 'Objeto no clasificado';
  }

  static Future<List<String>> detectObjects(File imageFile) async {
    // TODO: Implement object detection
    return ['objeto1', 'objeto2'];
  }

  static Future<String> suggestCategory(String itemName, File? imageFile) async {
    // Simple keyword-based category suggestion
    final lowerName = itemName.toLowerCase();
    
    if (lowerName.contains('libro') || lowerName.contains('book')) {
      return 'Libros';
    } else if (lowerName.contains('ropa') || lowerName.contains('camisa') || 
               lowerName.contains('pantalón')) {
      return 'Ropa';
    } else if (lowerName.contains('herramienta') || lowerName.contains('martillo')) {
      return 'Herramientas';
    } else if (lowerName.contains('comida') || lowerName.contains('alimento')) {
      return 'Alimentos';
    } else if (lowerName.contains('electrónico') || lowerName.contains('celular')) {
      return 'Electrónicos';
    }
    
    return 'General';
  }
}
