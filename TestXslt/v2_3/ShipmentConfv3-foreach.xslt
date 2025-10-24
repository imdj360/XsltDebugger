<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="urn:local">

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <!-- Parse mixed date/time strings and normalize to UTC.
       If input lacks a timezone, PT0H (Z) is *added* with no clock shift. -->
  <xsl:function name="local:to-utc-datetime" as="xs:dateTime?">
    <xsl:param name="s" as="xs:string?"/>
    <xsl:variable name="trim" select="normalize-space($s)"/>
    <xsl:choose>
      <xsl:when test="$trim = ''">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- normalize "YYYY-MM-DD HH:MM(:SS)?" to 'T' form -->
        <xsl:variable name="norm" select="replace($trim, '\s+', 'T')"/>
        <xsl:variable name="dt" as="xs:dateTime">
          <xsl:choose>
            <xsl:when test="contains($norm,'T')">
              <xsl:sequence select="xs:dateTime($norm)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="xs:dateTime(concat($norm, 'T00:00:00'))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="adjust-dateTime-to-timezone($dt, xs:dayTimeDuration('PT0H'))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="/">
    <TransportConfirmations>
      <xsl:for-each select="/ShipmentConfirmation/Orders/OrderItems">
        <Confirmation>
          <CompanyName>
            <xsl:value-of select="../../Orders/CustomerName"/>
          </CompanyName>

          <Reference>
            <xsl:value-of select="../../Reference"/>
          </Reference>

          <OrderNumber>
            <xsl:value-of select="../Number"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="Sequence"/>
          </OrderNumber>

          <Quantity>
            <xsl:variable name="net" select="normalize-space(../../Net)"/>
            <xsl:value-of
              select="if ($net castable as xs:decimal)
                      then format-number(xs:decimal($net), '0.00')
                      else ''"/>
          </Quantity>

          <Unit>KG</Unit>

          <Date>
            <!-- Collect UTC datetimes; ignore any that fail to parse -->
            <xsl:variable name="dates-utc" as="xs:dateTime*">
              <xsl:for-each select="OperationReports/ReportInfo/OperationReportDate">
                <xsl:variable name="d" select="local:to-utc-datetime(string(.))"/>
                <xsl:if test="exists($d)">
                  <xsl:sequence select="$d"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>

            <!-- Format the earliest report date (change min→max for latest) -->
            <xsl:value-of
              select="if (exists($dates-utc))
                      then format-date(xs:date(min($dates-utc)), '[D01].[M01].[Y0001]')
                      else ''"/>
          </Date>

          <LicensePlate>
            <xsl:value-of select="../../LicensePlate"/>
          </LicensePlate>

        <xsl:for-each select="OperationReports/ReportInfo/OperationReportDate">
          <OperationReportDate>Dummy: <xsl:value-of select="."/></OperationReportDate>
        </xsl:for-each>

          <OperationCode>
            <xsl:value-of select="OperationCode"/>
          </OperationCode>
        </Confirmation>
      </xsl:for-each>
    </TransportConfirmations>
  </xsl:template>
</xsl:stylesheet>