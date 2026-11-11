import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/homework_model.dart';
import '../../../../services/vision_ai_service.dart';
import '../../../homework/data/homework_service.dart';
import 'scan_result_page.dart';
import 'step_confirm_page.dart';

/// Kamera preview + galereya/demo → Vision AI tahlil.
class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key, required this.homework});

  final HomeworkModel homework;

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _controller;
  var _cameraReady = false;
  var _cameraFailed = false;
  var _analyzing = false;
  String? _previewPath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      setState(() => _cameraFailed = true);
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraFailed = true);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraReady = true;
        _cameraFailed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<String> _persistImage(String sourcePath) async {
    final dir = await getTemporaryDirectory();
    final scansDir = Directory(p.join(dir.path, 'scans'));
    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }
    final dest = p.join(
      scansDir.path,
      'hw_${widget.homework.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<void> _takePicture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    try {
      final file = await ctrl.takePicture();
      final path = await _persistImage(file.path);
      setState(() => _previewPath = path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.visionCameraError)),
      );
    }
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final path = await _persistImage(file.path);
    setState(() => _previewPath = path);
  }

  Future<void> _demoScan() async {
    // Kamera yo‘q muhit: bo‘sh fayl yo‘li bilan stub tahlil.
    final dir = await getTemporaryDirectory();
    final path = p.join(
      dir.path,
      'scans',
      'demo_${widget.homework.id}.txt',
    );
    await Directory(p.dirname(path)).create(recursive: true);
    await File(path).writeAsString('demo-notebook-scan');
    setState(() => _previewPath = path);
  }

  Future<void> _analyze() async {
    final path = _previewPath;
    if (path == null) return;
    setState(() => _analyzing = true);
    try {
      final vision = kDebugMode && path.endsWith('.txt')
          ? StubVisionAiService()
          : context.read<VisionAiService>();
      final homeworkService = context.read<HomeworkService>();
      final analysis = await vision.analyzeNotebookPage(
        imagePath: path,
        homework: widget.homework,
      );
      final updated = await homeworkService.applyVisionScan(
        homework: widget.homework,
        analysis: analysis,
      );
      if (!mounted) return;
      final page = mustConfirmSteps(analysis)
          ? StepConfirmPage(homework: updated, analysis: analysis)
          : ScanResultPage(homework: updated, analysis: analysis);
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );
    } on VisionAnalysisException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.messageUz)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.somethingWrong)),
      );
    } finally {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: Text(widget.homework.titleUz),
        backgroundColor: AppColors.primaryDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildPreview(),
              ),
            ),
          ),
          if (_analyzing)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 8),
                  Text(
                    AppStrings.visionAnalyzing,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: _previewPath == null
                ? Column(
                    children: [
                      if (_cameraReady)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _analyzing ? null : _takePicture,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text(AppStrings.visionCapture),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _analyzing ? null : _pickGallery,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                side: const BorderSide(color: AppColors.accent),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              icon: const Icon(Icons.photo_library),
                              label: const Text(AppStrings.visionPickGallery),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (kDebugMode)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _analyzing ? null : _demoScan,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textOnPrimary,
                                  side: const BorderSide(
                                    color: AppColors.primaryLight,
                                  ),
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                icon: const Icon(Icons.science),
                                label: const Text(AppStrings.visionDemoScan),
                              ),
                            ),
                        ],
                      ),
                      if (_cameraFailed)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            AppStrings.visionCameraError,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _analyzing
                              ? null
                              : () => setState(() => _previewPath = null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: const Text(AppStrings.visionRetake),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _analyzing ? null : _analyze,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text(AppStrings.visionAnalyze),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_previewPath != null) {
      final file = File(_previewPath!);
      if (_previewPath!.endsWith('.txt') || !file.existsSync()) {
        return Container(
          color: AppColors.primary,
          alignment: Alignment.center,
          child: const Text(
            'Demo skan tayyor\nAI tahlilni bosing',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.accent, fontSize: 16),
          ),
        );
      }
      return Image.file(file, fit: BoxFit.cover, width: double.infinity);
    }

    if (_cameraReady && _controller != null) {
      return CameraPreview(_controller!);
    }

    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _cameraFailed ? Icons.no_photography : Icons.hourglass_top,
            size: 64,
            color: AppColors.accent,
          ),
          const SizedBox(height: 12),
          Text(
            _cameraFailed
                ? AppStrings.visionNoCamera
                : AppStrings.loading,
            style: const TextStyle(color: AppColors.textOnPrimary),
          ),
        ],
      ),
    );
  }
}
