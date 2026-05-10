import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/constants.dart';

enum ConnectivityState { online, offline, syncing }

class ConnectivityWidget extends StatefulWidget {
  const ConnectivityWidget({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  final Widget child;
  final bool showBanner;

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  ConnectivityState _state = ConnectivityState.online;
  bool _wasOffline = false;

  void _updateState(bool isOnline) {
    if (!mounted) return;
    
    setState(() {
      if (isOnline) {
        if (_state == ConnectivityState.offline) {
          _state = ConnectivityState.syncing;
          _wasOffline = true;
        } else {
          _state = ConnectivityState.online;
        }
      } else {
        _state = ConnectivityState.offline;
        _wasOffline = false;
      }
    });

    if (_state == ConnectivityState.syncing) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _state = ConnectivityState.online);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    _updateState(true);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBanner) return widget.child;

    return Column(
      children: [
        AnimatedContainer(
          duration: AppDurations.fast,
          height: _state == ConnectivityState.online && !_wasOffline ? 0 : 32,
          child: AnimatedOpacity(
            opacity: _state == ConnectivityState.online && !_wasOffline ? 0 : 1,
            duration: AppDurations.fast,
            child: _buildBanner(context),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    String message;
    IconData icon;

    switch (_state) {
      case ConnectivityState.offline:
        backgroundColor = AppColors.warning.withValues(alpha: 0.9);
        textColor = Colors.black87;
        message = 'You are offline. Changes will sync when connected.';
        icon = Icons.cloud_off_rounded;
        break;
      case ConnectivityState.syncing:
        backgroundColor = AppColors.success.withValues(alpha: 0.9);
        textColor = Colors.white;
        message = 'Syncing...';
        icon = Icons.sync_rounded;
        break;
      case ConnectivityState.online:
        if (_wasOffline) {
          backgroundColor = AppColors.success.withValues(alpha: 0.9);
          textColor = Colors.white;
          message = 'Back online!';
          icon = Icons.check_circle_outline_rounded;
        } else {
          return const SizedBox.shrink();
        }
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}