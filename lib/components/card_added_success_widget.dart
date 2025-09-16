import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CardAddedSuccessWidget extends StatelessWidget {
  const CardAddedSuccessWidget({super.key, required this.card});

  final Map<String, dynamic> card;

  String _masked() {
    final masked = (card['numberMasked'] ?? '').toString();
    if (masked.isNotEmpty) return masked;
    final last4 = (card['last4'] ?? '').toString();
    return last4.isNotEmpty ? '**** **** **** $last4' : '**** **** **** ____';
    }

  @override
  Widget build(BuildContext context) {
    final brand = (card['brand'] ?? '').toString().toUpperCase();
    final name = (card['name'] ?? '').toString();
    final masked = _masked();

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryText,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x33000000))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Card added successfully',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  color: FlutterFlowTheme.of(context).alternate,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            [if (brand.isNotEmpty) brand, if (name.isNotEmpty) name]
                .join(' • '),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            masked,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).alternate,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).tertiary,
                foregroundColor: FlutterFlowTheme.of(context).alternate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Great!'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
