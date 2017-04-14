<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:template name="TimeStorage">
		<xsl:param name="time"/>
		<xsl:param name="name"/>
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Days</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after($time, 'P'), 'D')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Hours</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after($time, 'T'), 'H')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Minutes</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after($time, 'H'), 'M')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Seconds</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after($time, 'M'), '.')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="TaskingInfo">
		<xsl:param name="info"/>
		
		<xsl:if test="$info">
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">TaskingInfo</xsl:attribute>
				
				<xsl:apply-templates select="$info/CommandTarget"/>
				<xsl:apply-templates select="$info/SearchMask"/>
				<xsl:apply-templates select="$info/SearchPath"/>
				<xsl:apply-templates select="$info/SearchAfterDate"/>
				<xsl:apply-templates select="$info/SearchBeforeDate"/>
				<xsl:apply-templates select="$info/SearchAge"/>
				<xsl:apply-templates select="$info/SearchMaxMatches"/>
				<xsl:apply-templates select="$info/TaskType"/>
				<xsl:apply-templates select="$info/SearchParam"/>
				
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">Recursive</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$info/SearchRecursive">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>false</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="TaskingResult">
		<xsl:param name="info"/>
		
		<xsl:if test="$info">
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">TaskResult</xsl:attribute>
				
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Result</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="CommandTarget">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Target</xsl:attribute>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Local</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@type = 'local'">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Location</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@type = 'local'">
						<xsl:text>localhost</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
			
	<xsl:template match="SearchMask">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SearchMask</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="SearchPath">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SearchPath</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="SearchParam">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SearchParam</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="SearchAfterDate">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SearchAfterDate</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Date</xsl:attribute>
				<xsl:value-of select="substring-before(., 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Time</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(., 'T'), '.')"/>
			</xsl:element>
			
		</xsl:element>	
	</xsl:template>

	<xsl:template match="SearchBeforeDate">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SearchBeforeDate</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Date</xsl:attribute>
				<xsl:value-of select="substring-before(., 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Time</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(., 'T'), '.')"/>
			</xsl:element>
			
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="SearchAge">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SearchAge</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Days</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(., 'P'), 'D')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Hours</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(., 'T'), 'H')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Minutes</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(., 'H'), 'M')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Seconds</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(., 'M'), '.')"/>
			</xsl:element>
		</xsl:element>	
	</xsl:template>

	<xsl:template match="SearchMaxMatches">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SearchMaxMatches</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="TaskType">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TaskType</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>	
	</xsl:template>
</xsl:transform>
