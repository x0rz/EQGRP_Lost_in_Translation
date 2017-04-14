<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	

	<!--
		This code is stolen from XSLT Cookbook, by Sal Mangano.  Page 40-42
	-->
	<xsl:variable name="base-lower" select="'0123456789abcdefghijklmnopqrstuvwxyz'" />
	
	<xsl:variable name="base-upper" select="'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:template name="math-convert-base">
		<xsl:param name="number"/>
		<xsl:param name="from-base"/>
		<xsl:param name="to-base" />
		
		<xsl:variable name="number-base10">
			<xsl:call-template name="convert-to-base-10">
				<xsl:with-param name="number" select="$number"/>
				<xsl:with-param name="from-base" select="$from-base"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:call-template name="convert-from-base-10">
				<xsl:with-param name="number" select="$number-base10"/>
				<xsl:with-param name="to-base" select="$to-base"/>
		</xsl:call-template>
		
	</xsl:template>

	
	<xsl:template name="convert-to-base-10">
		<xsl:param name="number"/>
		<xsl:param name="from-base"/>
		<xsl:variable name="num"
			select="translate($number, $base-upper, $base-lower)"/>
		<xsl:variable name="valid-in-chars"
			select="substring($	base-lower, 1, $from-base)" />
			
		<xsl:choose>
			<!-- <xsl:when test="($from-base $lt; '2') or ($from-base > '36')">NaN</xsl:when> -->
			<xsl:when test="2 > $from-base">NaN</xsl:when>
			<xsl:when test="$from-base > 36">NaN</xsl:when>
			<xsl:when test="not($num) or translate($num, $valid-in-chars, '')">NaN</xsl:when>
			<xsl:when test="$from-base = 10"><xsl:value-of select="$number"/></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="convert-to-base-10-impl">
					<xsl:with-param name="number" select="$num"/>
					<xsl:with-param name="from-base" select="$from-base"/>
					<xsl:with-param name="from-chars" select="$valid-in-chars"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="convert-to-base-10-impl">
		<xsl:param name="number"/>
		<xsl:param name="from-base"/>
		<xsl:param name="from-chars"/>
		
		<xsl:param name="result" select="0" />
		<xsl:variable name="value"
				select="string-length(substring-before($from-chars, substring($number, 1, 1)))"/>
				
		<xsl:variable name="total" select="$result * $from-base + $value"/>
		
		<xsl:choose>
			<xsl:when test="string-length($number) = 1">
				<xsl:value-of select="$total"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="convert-to-base-10-impl">
					<xsl:with-param name="number" select="substring($number, 2)"/>
					<xsl:with-param name="from-base" select="$from-base"/>
					<xsl:with-param name="from-chars" select="$from-chars"/>
					<xsl:with-param name="result" select="$total"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="convert-from-base-10">
		<xsl:param name="number"/>
		<xsl:param name="to-base"/>
		
		<xsl:choose>
			<xsl:when test="2 > $to-base">NaN</xsl:when>
			<xsl:when test="$to-base > 36">NaN</xsl:when>
			<xsl:when test="number($number) != number($number)">NaN</xsl:when>
			<xsl:when test="$to-base = 10">
				<xsl:value-of select="$number"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="convert-from-base-10-impl">
					<xsl:with-param name="number" select="$number"/>
					<xsl:with-param name="to-base" select="$to-base"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="convert-from-base-10-impl">
		<xsl:param name="number"/>
		<xsl:param name="to-base"/>
		<xsl:param name="result"/>
		
		<xsl:variable name="to-base-digit"
			select="substring($base-lower, $number mod $to-base + 1, 1)"/>

		<xsl:choose>
			<xsl:when test="$number >= $to-base">
				<xsl:call-template name="convert-from-base-10-impl">
					<xsl:with-param name="number" select="floor($number div $to-base)" />
					<xsl:with-param name="to-base" select="$to-base"/>
					<xsl:with-param name="result"  select="concat($to-base-digit, $result)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($to-base-digit, $result)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:transform>