<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Time"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Time">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TimeItem</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="LocalTime">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LocalTime</xsl:attribute>
			<xsl:call-template name="StoreDate">
				<xsl:with-param name="date" select="."/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="LocalTimeSeconds">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LocalTimeSeconds</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="SystemTime">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">GmtTime</xsl:attribute>
			<xsl:call-template name="StoreDate">
				<xsl:with-param name="date" select="."/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="SystemTimeSeconds">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">GmtTimeSeconds</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="TimeZone">
		<xsl:element name="StringValue">
			<xsl:attribute name="name">Bias</xsl:attribute>
			<xsl:if test="Bias/@negative = 'true'">
				<xsl:text>-</xsl:text>
			</xsl:if>
				
			<xsl:value-of select="substring-before(substring-after(Bias, 'T'), 'H')"/>
			<xsl:text>:</xsl:text>
			<xsl:value-of select="substring-before(substring-after(Bias, 'H'), 'M')"/>
		</xsl:element>
		<xsl:element name="StringValue">
			<xsl:attribute name="name">CurrentState</xsl:attribute>
			<xsl:value-of select="CurrentState"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="DaylightSavingsTime">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DaylightSavingsTime</xsl:attribute>
			
			<xsl:call-template name="Setting">
				<xsl:with-param name="setting" select="Standard"/>
			</xsl:call-template>
			<xsl:call-template name="Setting">
				<xsl:with-param name="setting" select="Daylight"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="StoreDate">
		<xsl:param name="date"/>
		
		<xsl:element name="StringValue">
			<xsl:attribute name="name">date</xsl:attribute>
			<xsl:value-of select="substring-before($date, 'T')"/>
		</xsl:element>
		<xsl:element name="StringValue">
			<xsl:attribute name="name">time</xsl:attribute>
			<xsl:value-of select="substring-before(substring-after($date, 'T'), '.')"/>
		</xsl:element>
		<xsl:element name="StringValue">
			<xsl:attribute name="name">nanoseconds</xsl:attribute>
			<xsl:value-of select="substring-after($date, '.')"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="Setting">
		<xsl:param name="setting"/>
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name"><xsl:value-of select="name($setting)"/></xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="$setting/Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Bias</xsl:attribute>
				<xsl:if test="$setting/Bias/@negative = 'true'">
					<xsl:text>-</xsl:text>
				</xsl:if>
				
				<xsl:value-of select="substring-before(substring-after($setting/Bias, 'T'), 'H')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="substring-before(substring-after($setting/Bias, 'H'), 'M')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Month</xsl:attribute>
				<xsl:value-of select="$setting/ConversionDate/@month"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Week</xsl:attribute>
				<xsl:value-of select="$setting/ConversionDate/@week"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Day</xsl:attribute>
				<xsl:value-of select="$setting/ConversionDate/@dayOfWeek"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	
</xsl:transform>
