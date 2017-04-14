<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Plugins"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Plugins"> 
		<xsl:apply-templates select="Local"/>
		<xsl:apply-templates select="Remote"/>
	</xsl:template>
	
	<xsl:template match="Local">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Local</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			
			<xsl:apply-templates select="Plugin"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Remote">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Remote</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			
			<xsl:apply-templates select="Plugin"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Plugin">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Plugin</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">LoadCount</xsl:attribute>
				<xsl:value-of select="@loadCount"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LoaderInfo</xsl:attribute>
				<xsl:value-of select="@loaderInfo"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Core</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Core">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">ReallyLoaded</xsl:attribute>
				<xsl:choose>
					<xsl:when test="NotLoaded">
						<xsl:text>false</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>true</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:apply-templates select="VersionInformation"/>
			<xsl:apply-templates select="Registered"/>
			<xsl:apply-templates select="Acquired"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="VersionInformation">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Version</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">BuildEnvironment</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Major</xsl:attribute>
					<xsl:value-of select="BuildEnvironment/@major"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Minor</xsl:attribute>
					<xsl:value-of select="BuildEnvironment/@minor"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Revision</xsl:attribute>
					<xsl:value-of select="BuildEnvironment/@revision"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">TypeValue</xsl:attribute>
					<xsl:value-of select="BuildEnvironment/@type"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Type</xsl:attribute>
					<xsl:value-of select="BuildEnvironment/@typeStr"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Lla</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Major</xsl:attribute>
					<xsl:value-of select="LlaVersion/@major"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Minor</xsl:attribute>
					<xsl:value-of select="LlaVersion/@minor"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Revision</xsl:attribute>
					<xsl:value-of select="LlaVersion/@revision"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Module</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Major</xsl:attribute>
					<xsl:value-of select="ModuleVersion/@major"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Minor</xsl:attribute>
					<xsl:value-of select="ModuleVersion/@minor"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Revision</xsl:attribute>
					<xsl:value-of select="ModuleVersion/@revision"/>
				</xsl:element>
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Flags</xsl:attribute>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">Value</xsl:attribute>
						<xsl:value-of select="ModuleVersion/@typeFlags"/>
					</xsl:element>
					<xsl:element name="BoolValue">
						<xsl:attribute name="name">Lp</xsl:attribute>
						<xsl:choose>
							<xsl:when test="ModuleVersion/ModuleTypeFlagLp">
								<xsl:text>true</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>false</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="BoolValue">
						<xsl:attribute name="name">Target</xsl:attribute>
						<xsl:choose>
							<xsl:when test="ModuleVersion/ModuleTypeFlagTarget">
								<xsl:text>true</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>false</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Registered">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">RegisteredApis</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Interface</xsl:attribute>
				<xsl:text>0x</xsl:text><xsl:value-of select="substring-before(., ':')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Provider</xsl:attribute>
				<xsl:text>0x</xsl:text><xsl:value-of select="substring-before(substring-after(., ':'), '.')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
		
	<xsl:template match="Acquired">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AcquiredApis</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Interface</xsl:attribute>
				<xsl:text>0x</xsl:text><xsl:value-of select="substring-before(., ':')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Provider</xsl:attribute>
				<xsl:text>0x</xsl:text><xsl:value-of select="substring-before(substring-after(., ':'), '.')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ProvidedBy</xsl:attribute>
				<xsl:value-of select="@module"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>

