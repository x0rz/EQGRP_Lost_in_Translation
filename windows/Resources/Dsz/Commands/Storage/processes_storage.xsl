<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Initial">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">InitialProcessListItem</xsl:attribute>
	
			<xsl:apply-templates select="Process"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Started">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">StartProcessListItem</xsl:attribute>
				
			<xsl:apply-templates select="Process"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Stopped">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">StopProcessListItem</xsl:attribute>
				
			<xsl:apply-templates select="Process"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Process">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">user</xsl:attribute>
				<xsl:value-of select="@user"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">CpuTime</xsl:attribute>
				
				<xsl:variable name="days"    select="substring-before(substring-after(CpuTime, 'P'), 'D')"/>
				<xsl:variable name="hours"   select="substring-before(substring-after(CpuTime, 'T'), 'H')"/>
				<xsl:variable name="minutes" select="substring-before(substring-after(CpuTime, 'H'), 'M')"/>
				<xsl:variable name="seconds" select="substring-before(substring-after(CpuTime, 'M'), '.')"/>
				
				<xsl:element name="IntValue">
					<xsl:attribute name="name">seconds</xsl:attribute>
					<xsl:call-template name="chopZero">
						<xsl:with-param name="number" select="$seconds"/>
					</xsl:call-template>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">minutes</xsl:attribute>
					<xsl:call-template name="chopZero">
						<xsl:with-param name="number" select="$minutes"/>
					</xsl:call-template>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">hours</xsl:attribute>
					<xsl:call-template name="chopZero">
						<xsl:with-param name="number" select="number($hours) + (number($days) * 24)"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:element>	
					
			<xsl:call-template name="FileTimeFunction">
				<xsl:with-param name="time" select="CreateTime"/>
				<xsl:with-param name="var"  select="'Created'"/>
			</xsl:call-template>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">display</xsl:attribute>
				<xsl:value-of select="@display"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">parentId</xsl:attribute>
				<xsl:value-of select="@parent"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">path</xsl:attribute>
				<xsl:value-of select="ExecutablePath"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">description</xsl:attribute>
				<xsl:value-of select="Description"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Is64Bit</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Is64Bit">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Is32Bit</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Is32Bit">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
		
	</xsl:template>
	
	<xsl:template name="chopZero">
		<xsl:param name="number"/>
		
		<xsl:choose>
			<xsl:when test="($number != 0) and (starts-with($number, '0'))">
				<xsl:call-template name="chopZero">
					<xsl:with-param name="number" select="substring-after($number, '0')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$number"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">date</xsl:attribute>
				<xsl:value-of select="substring-before($time, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after($time, 'T'), '.')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">typeValue</xsl:attribute>
				<xsl:value-of select="$time/@typeValue"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>