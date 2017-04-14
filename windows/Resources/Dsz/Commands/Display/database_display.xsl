<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="DatabaseOpen">
		<xsl:if test="ConnectionId">
			<xsl:text>Connection handle: </xsl:text>
			<xsl:value-of select="ConnectionId"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="DatabaseExec">
		<xsl:choose>
			<xsl:when test="count(Column) = 0">
				<xsl:text>No data</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>|</xsl:text>
				<xsl:call-template name="PrintColumns"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:call-template name="PrintRows"/>
			</xsl:otherwise>
		</xsl:choose>
		
		
	</xsl:template>
	
	<xsl:template name="LongestCell">
		<xsl:param name="column"/>
		<xsl:param name="row" select="1" />
		<xsl:param name="width" select="1" />
		
		
		<xsl:choose>
			<!-- past the last row -->
			<xsl:when test="$row &gt; count(Row)">
				<xsl:value-of select="$width + 2"/>
			</xsl:when>
			<xsl:when test="string-length(Row[$row]/Cell[$column]) &gt; $width">
				<xsl:call-template name="LongestCell">
					<xsl:with-param name="column" select="$column"/>
					<xsl:with-param name="row"    select="$row + 1"/>
					<xsl:with-param name="width"  select="string-length(Row[$row]/Cell[$column])"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="LongestCell">
					<xsl:with-param name="column" select="$column"/>
					<xsl:with-param name="row"    select="$row + 1"/>
					<xsl:with-param name="width"  select="$width"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name="PrintColumns">
		<xsl:param name="index" select="1"/>
		
		<xsl:if test="$index &lt;= count(Column)">
		
			<xsl:variable name="width">
				<xsl:call-template name="LongestCell">
					<xsl:with-param name="column" select="$index"/>
					<xsl:with-param name="width" select="string-length(Column[$index])"/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="(($width - string-length(Column[$index]) - 1) div 2)"/>
			</xsl:call-template>
			
			<xsl:value-of select="Column[$index]" />
			
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="((($width - string-length(Column[$index]))) div 2)"/>
			</xsl:call-template>
			
			<xsl:text>|</xsl:text>
			
			<xsl:call-template name="PrintColumns">
				<xsl:with-param name="index" select="$index + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PrintRows">
		<xsl:param name="index" select="1"/>
		
		<xsl:if test="$index &lt;= count(Row)">
			<xsl:text>|</xsl:text>
			<xsl:call-template name="PrintRow">
				<xsl:with-param name="row" select="$index"/>
			</xsl:call-template>
			
			<xsl:call-template name="PrintReturn"/>
			
			<xsl:call-template name="PrintRows">
				<xsl:with-param name="index" select="$index + 1"/>
			</xsl:call-template>
			
		</xsl:if>
		
	</xsl:template>

	<xsl:template name="PrintRow">
		<xsl:param name="row" select="1" />
		<xsl:param name="column" select="1"/>
		
		<xsl:if test="$column &lt;= count(Column)">
		
			<xsl:variable name="width">
				<xsl:call-template name="LongestCell">
					<xsl:with-param name="column" select="$column"/>
					<xsl:with-param name="width" select="string-length(Column[$column])" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="text">
				<xsl:value-of select="Row[$row]/Cell[$column]"/>
			</xsl:variable>

			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="(($width - string-length($text) - 1) div 2)"/>
			</xsl:call-template>

			<xsl:value-of select="$text" />

			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="((($width - string-length($text))) div 2)"/>
			</xsl:call-template>
			
			<xsl:text>|</xsl:text>
			
			<xsl:call-template name="PrintRow">
				<xsl:with-param name="row" select="$row"/>
				<xsl:with-param name="column" select="$column + 1"/>
			</xsl:call-template>
		
		</xsl:if>
	</xsl:template>
	
</xsl:transform>