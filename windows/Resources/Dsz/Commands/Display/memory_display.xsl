<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/> 	

	<xsl:template match="Memory">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>Physical Load: </xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type">
				<xsl:choose>
					<xsl:when test="@physicalLoad &gt; 79">
						<xsl:text>Error</xsl:text>
					</xsl:when>
					<xsl:when test="@physicalLoad &gt; 50">
						<xsl:text>Warning</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Good</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="text">
				<xsl:value-of select="@physicalLoad" />
				<xsl:text>%</xsl:text>
			</xsl:with-param>
		</xsl:call-template>


		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="Physical"/>
		<xsl:apply-templates select="Page"/>
		<xsl:apply-templates select="Virtual"/>
	
	</xsl:template>
	
	<xsl:template match="Physical">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Physical Memory:</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>           Total : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="skipBillions" select="'true'"/>
					<xsl:with-param name="skipMillions" select="'true'"/>
					<xsl:with-param name="number" select="@total div (1024 * 1024)"/>
				</xsl:call-template>
				<xsl:text> MB</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			
				<xsl:text>       Available : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="skipBillions" select="'true'"/>
					<xsl:with-param name="skipMillions" select="'true'"/>
					<xsl:with-param name="number" select="@available div (1024 * 1024)"/>
				</xsl:call-template>
				<xsl:text> MB</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:if test="@available &lt; (1024 * 1024)">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Error'"/>
				<xsl:with-param name="text">
					<xsl:text>    **** PHYSICAL MEMORY IS VERY LOW ****</xsl:text>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Page">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Page Space:</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>           Total : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="skipBillions" select="'true'"/>
					<xsl:with-param name="skipMillions" select="'true'"/>
					<xsl:with-param name="number" select="@total div (1024 * 1024)"/>
				</xsl:call-template>
				<xsl:text> MB</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				
				<xsl:text>       Available : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="skipBillions" select="'true'"/>
					<xsl:with-param name="skipMillions" select="'true'"/>
					<xsl:with-param name="number" select="@available div (1024 * 1024)"/>
				</xsl:call-template>
				<xsl:text> MB</xsl:text>
				<xsl:call-template name="PrintReturn"/>			
			</xsl:with-param>
		</xsl:call-template>
	
		<xsl:if test="(@total != 0) and (@available &lt; (1024 * 1024))">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Error'"/>
				<xsl:with-param name="text">
					<xsl:text>    **** PAGE SPACE IS VERY LOW ****</xsl:text>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	
	</xsl:template>
	
	<xsl:template match="Virtual">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Virtual Memory:</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>           Total : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="skipBillions" select="'true'"/>
					<xsl:with-param name="skipMillions" select="'true'"/>
					<xsl:with-param name="number" select="@total div (1024 * 1024)"/>
				</xsl:call-template>
				<xsl:text> MB</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				
				<xsl:text>       Available : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="skipBillions" select="'true'"/>
					<xsl:with-param name="skipMillions" select="'true'"/>
					<xsl:with-param name="number" select="@available div (1024 * 1024)"/>
				</xsl:call-template>
				<xsl:text> MB</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	
		<xsl:if test="@available &lt; (1024 * 1024)">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Error'"/>
				<xsl:with-param name="text">
					<xsl:text>    **** VIRTUAL MEMORY IS VERY LOW ****</xsl:text>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>
	
</xsl:transform>
