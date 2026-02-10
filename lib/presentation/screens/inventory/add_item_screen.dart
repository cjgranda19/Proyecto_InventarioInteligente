import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:proyecto/domain/entities/inventory_item.dart';
import 'package:proyecto/domain/entities/category.dart';
import 'package:proyecto/presentation/providers/inventory_provider.dart';
import 'package:proyecto/presentation/providers/category_provider.dart';
import 'package:proyecto/presentation/widgets/atoms/custom_button.dart';
import 'package:proyecto/presentation/widgets/atoms/custom_textfield.dart';
import 'package:proyecto/core/services/ocr_service.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final String userId;
  final InventoryItem? item;

  const AddItemScreen({
    Key? key,
    required this.userId,
    this.item,
  }) : super(key: key);

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _locationController = TextEditingController();
  
  String? _selectedCategoryId;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzingImage = false;
  String? _aiSuggestion;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      // Cargar todos los datos existentes del item
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description ?? '';
      _quantityController.text = widget.item!.quantity.toString();
      _locationController.text = widget.item!.location ?? '';
      _selectedCategoryId = widget.item!.categoryId;
      
      // Cargar la imagen existente si hay
      if (widget.item!.localImagePath != null && 
          File(widget.item!.localImagePath!).existsSync()) {
        _imageFile = File(widget.item!.localImagePath!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isAnalyzingImage = true;
          _aiSuggestion = null;
        });
        
        // Analizar imagen con IA
        await _analyzeImageWithAI(_imageFile!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImageWithAI(File imageFile) async {
    try {
      // Analizar imagen con ML Service
      final result = await MlService.analyzeProductImage(imageFile);
      
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
        });
        
        // Si encontró información válida
        if (result['productName'].isNotEmpty) {
          // Mostrar diálogo con sugerencias de IA
          _showAISuggestionsDialog(result);
        } else {
          // No se detectó texto, solo notificar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(' No se detectó texto en la imagen. Ingresa los datos manualmente.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al analizar imagen: $e')),
        );
      }
    }
  }

  void _showAISuggestionsDialog(Map<String, dynamic> aiResult) {
    final productName = aiResult['productName'];
    final suggestedCategory = aiResult['suggestedCategory'];
    final extractedText = aiResult['extractedText'];
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue),
              SizedBox(width: 8),
              Text(' IA detectó el producto'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'La IA ha analizado la imagen:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Producto: $productName',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.category, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Categoría: $suggestedCategory',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              if (extractedText.length > productName.length) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Texto extraído:',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    extractedText,
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Ignorar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _applyAISuggestions(aiResult);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyAISuggestions(Map<String, dynamic> aiResult) async {
    final categoryState = ref.read(categoryProvider(widget.userId));
    
    // Aplicar nombre del producto
    _nameController.text = aiResult['productName'];
    
    // Buscar y aplicar categoría sugerida
    final suggestedCategoryName = aiResult['suggestedCategory'];
    Category? matchingCategory;
    
    try {
      matchingCategory = categoryState.categories.firstWhere(
        (cat) => cat.name == suggestedCategoryName,
      );
    } catch (e) {
      // La categoría no existe, crearla automáticamente
      print('🆕 Categoría "$suggestedCategoryName" no existe, creándola...');
      
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: suggestedCategoryName,
        description: 'Categoría creada automáticamente por IA',
        iconName: 'category',
        colorHex: '#2196F3', // Azul por defecto
        userId: widget.userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      
      await ref.read(categoryProvider(widget.userId).notifier).createCategory(newCategory);
      matchingCategory = newCategory;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Nueva categoría "$suggestedCategoryName" creada automáticamente'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    
    setState(() {
      _selectedCategoryId = matchingCategory!.id;
      _aiSuggestion = '🤖 Sugerido por IA';
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Sugerencias de IA aplicadas. Puedes modificarlas si es necesario.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una categoría')),
      );
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final item = InventoryItem(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        localImagePath: _imageFile?.path,
        userId: widget.userId,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.item == null) {
        await ref.read(inventoryProvider(widget.userId).notifier).createItem(item);
      } else {
        await ref.read(inventoryProvider(widget.userId).notifier).updateItem(item);
      }

      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga
        Navigator.pop(context); // Volver a pantalla anterior
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.item == null ? '✓ Item guardado exitosamente' : '✓ Item actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Agregar Item' : 'Editar Item'),
        actions: widget.item != null ? [
          // Indicador de modo edición
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 4),
                Text(
                  'Editando',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner informativo en modo edición
              if (widget.item != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ' Editando: ${widget.item!.name}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Los datos actuales están cargados. Modifica lo que necesites.',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Imagen
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imageFile != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            // Badge superior indicando si es imagen original o nueva
                            if (widget.item != null && !_isAnalyzingImage)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.photo, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Imagen actual',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Overlay de análisis de IA
                            if (_isAnalyzingImage)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        ' Analizando imagen con IA...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Botón para cambiar imagen (modo edición)
                            if (widget.item != null && !_isAnalyzingImage)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: ElevatedButton.icon(
                                  onPressed: _showImageSourceDialog,
                                  icon: const Icon(Icons.camera_alt, size: 16),
                                  label: const Text('Cambiar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.item == null 
                                ? 'Toca para agregar foto'
                                : 'Toca para cambiar foto',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ' IA detectará el producto',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_aiSuggestion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _aiSuggestion!,
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              CustomTextField(
                label: 'Nombre del Item',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Descripción',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Selector de categoría
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: categoryState.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Cantidad',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: 'Ubicación',
                      controller: _locationController,
                      prefixIcon: Icons.location_on,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: widget.item == null ? 'Agregar Item' : 'Guardar Cambios',
                onPressed: _saveItem,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
