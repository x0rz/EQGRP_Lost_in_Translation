<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="CommandData">
		<xsl:apply-templates select="TurnedOn"/>
		<xsl:apply-templates select="TurnedBackOn"/>
		<xsl:apply-templates select="TurnedOff"/>
		<xsl:apply-templates select="Status"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="TurnedOn">
		<xsl:text>Auditing has been enabled</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="TurnedBackOn">
		<xsl:text>Auditing has been re-enabled</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="TurnedOff">
		<xsl:text>Auditing has been disabled</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Status">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Auditing:</xsl:text>
		<xsl:value-of select="@current"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Event"/> 
	</xsl:template>

	<xsl:template match="Event">
		<xsl:choose>
			<xsl:when test="@subcategory">
				<xsl:choose>
					<xsl:when test="(string-length(@category) != 0) and (string-length(@subcategory) != 0)">
						<xsl:call-template name="PrintCategory">
							<xsl:with-param name="category" select="@category"/>
							<xsl:with-param name="subcategory" select="@subcategory"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="(string-length(@category) != 0) and (string-length(@subcategory) = 0)">
						<xsl:call-template name="PrintCategory">
							<xsl:with-param name="category" select="@category"/>
							<xsl:with-param name="subcategory" select="@subcategoryNative"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="(string-length(@category) = 0) and (string-length(@subcategory) != 0)">
						<xsl:call-template name="PrintCategory">
							<xsl:with-param name="category" select="@categoryNative"/>
							<xsl:with-param name="subcategory" select="@subcategory"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="PrintCategory">
							<xsl:with-param name="category" select="@categoryNative"/>
							<xsl:with-param name="subcategory" select="@subcategoryNative"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length(@category) != 0">
						<xsl:call-template name="Whitespace">
							<xsl:with-param name="i" select="40 - string-length(@category)" />
						</xsl:call-template>
						<xsl:value-of select="@category"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="Whitespace">
							<xsl:with-param name="i" select="40 - string-length(@categoryNative)" />
						</xsl:call-template>
						<xsl:value-of select="@categoryNative"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> -   </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
 		<xsl:choose>
   			<xsl:when test="OnSuccess">
    				<xsl:text>Success</xsl:text>
  			</xsl:when>
   			<xsl:otherwise>
    				<xsl:text>       </xsl:text>
   			</xsl:otherwise>
  		</xsl:choose>
  		<xsl:text>     </xsl:text>
  		<xsl:choose>
   			<xsl:when test="OnFailure">
    				<xsl:text>Failure</xsl:text>
   			</xsl:when>
   			<xsl:otherwise>
    				<xsl:text>       </xsl:text>
   			</xsl:otherwise>
  		</xsl:choose>
        <xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template name="PrintCategory">
		<xsl:param name="category"/>
		<xsl:param name="subcategory"/>

		<xsl:choose>
			<xsl:when test="string-length($subcategory)">
				<xsl:value-of select="$category"/>
				<xsl:text> : </xsl:text>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="55 - string-length($category) - string-length($subcategory)" />
				</xsl:call-template>
				<xsl:value-of select="$subcategory"/>
				<xsl:text> - </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="40 - string-length($category)" />
				</xsl:call-template>
				<xsl:value-of select="$category"/>
				<xsl:text> -   </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:transform>