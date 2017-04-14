<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">


  <xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="LocalGetDirectory"/>
			<xsl:apply-templates select="FileStart"/> 
			<xsl:apply-templates select="FileLocalName"/> 
			<xsl:apply-templates select="FileWrite"/> 
			<xsl:apply-templates select="FileStop"/>
			<xsl:apply-templates select="Conclusion"/> 
		</xsl:element>
	</xsl:template>

	<xsl:template match="LocalGetDirectory">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LocalGetDirectory</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">path</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FileStart">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileStart</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">FileName</xsl:attribute>
				<xsl:variable name="realpath" select="@realPath"/>
				<xsl:choose>
					<xsl:when test="string($realpath)">
						<xsl:value-of select="$realpath"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@remoteName"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">OriginalName</xsl:attribute>
				<xsl:value-of select="@remoteName"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Size</xsl:attribute>
				<xsl:value-of select="@size"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			
			<xsl:apply-templates select="FileTimes"/>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="FileLocalName">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileLocalName</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LocalName</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Subdir</xsl:attribute>
				<xsl:value-of select="@subdir"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="FileWrite">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileWrite</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">bytes</xsl:attribute>
				<xsl:value-of select="@bytes"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FileStop">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileStop</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">written</xsl:attribute>
				<xsl:value-of select="@bytesWritten"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Successful</xsl:attribute>
				<xsl:choose>
					<xsl:when test="starts-with(@status, 'SUCCESS')">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="Conclusion">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Conclusion</xsl:attribute>
		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumSuccess</xsl:attribute>
				<xsl:value-of select="@successFiles"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumPartial</xsl:attribute>
				<xsl:value-of select="@partialFiles"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumFailed</xsl:attribute>
				<xsl:value-of select="@failedFiles"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumSkipped</xsl:attribute>
				<xsl:value-of select="@skippedFiles"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>


	<!-- This template takes advantage of the below functionality -->

	<xsl:template match="FileTimes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileTimes</xsl:attribute>
			
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Modified"/>
					<xsl:with-param name="var"  select="'Modified'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Accessed"/>
					<xsl:with-param name="var"  select="'Accessed'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Created"/>
					<xsl:with-param name="var"  select="'Created'"/>
				</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="$time"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">locale</xsl:attribute>
				<xsl:value-of select="$time/@locale"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>