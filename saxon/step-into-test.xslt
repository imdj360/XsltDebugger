<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" indent="yes"/>

    <!-- Main template that calls other templates -->
    <xsl:template match="/">
        <root>
            <xsl:text>Starting transformation</xsl:text>

            <!-- Call first template -->
            <xsl:call-template name="processOrder"/>

            <xsl:text>Completed transformation</xsl:text>
        </root>
    </xsl:template>

    <!-- Named template 1: processOrder -->
    <xsl:template name="processOrder">
        <order>
            <xsl:text>Processing order...</xsl:text>

            <!-- Call nested template -->
            <xsl:call-template name="calculateTotal">
                <xsl:with-param name="amount" select="100"/>
            </xsl:call-template>

            <xsl:text>Order processed</xsl:text>
        </order>
    </xsl:template>

    <!-- Named template 2: calculateTotal (nested call) -->
    <xsl:template name="calculateTotal">
        <xsl:param name="amount"/>
        <total>
            <xsl:text>Calculating total...</xsl:text>
            <value>
                <xsl:value-of select="$amount * 1.1"/>
            </value>

            <!-- Call another nested template -->
            <xsl:call-template name="formatCurrency">
                <xsl:with-param name="value" select="$amount * 1.1"/>
            </xsl:call-template>
        </total>
    </xsl:template>

    <!-- Named template 3: formatCurrency (deeply nested) -->
    <xsl:template name="formatCurrency">
        <xsl:param name="value"/>
        <formatted>
            <xsl:text>$</xsl:text>
            <xsl:value-of select="format-number($value, '0.00')"/>
        </formatted>
    </xsl:template>

    <!-- Additional template to test step-over -->
    <xsl:template name="helperFunction">
        <helper>
            <xsl:text>This is a helper that should be skipped with step-over</xsl:text>
        </helper>
    </xsl:template>

</xsl:stylesheet>
