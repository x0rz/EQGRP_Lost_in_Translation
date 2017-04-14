<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Success"/>
	
	<xsl:template match="Time">
		<xsl:text>System Time</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>----------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Date : </xsl:text>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="dateTime" select="SystemTime"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Time : </xsl:text>
		<xsl:call-template name="PrintTime">
			<xsl:with-param name="dateTime" select="SystemTime"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Local Time</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>----------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Date : </xsl:text>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="dateTime" select="LocalTime"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Time : </xsl:text>
		<xsl:call-template name="PrintTime">
			<xsl:with-param name="dateTime" select="LocalTime"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Time Zone</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>----------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Bias : </xsl:text>
		<xsl:call-template name="PrintBias">
			<xsl:with-param name="bias" select="TimeZone/Bias"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   State : </xsl:text>
		<xsl:value-of select="TimeZone/CurrentState"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Name : </xsl:text>
		<xsl:value-of select="DaylightSavingsTime/Standard/Name"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Daylight Savings Time</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>---------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Bias : </xsl:text>
		<xsl:call-template name="PrintBias">
			<xsl:with-param name="bias" select="DaylightSavingsTime/Daylight/Bias"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Name : </xsl:text>
		<xsl:value-of select="DaylightSavingsTime/Daylight/Name"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="DaylightSavingsTime/Daylight/ConversionDate">
			<xsl:text>  Starts : </xsl:text>
			<xsl:call-template name="PrintConversionDate">
				<xsl:with-param name="date" select="DaylightSavingsTime/Daylight/ConversionDate"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>    Ends : </xsl:text>
			<xsl:call-template name="PrintConversionDate">
				<xsl:with-param name="date" select="DaylightSavingsTime/Standard/ConversionDate"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template name="PrintConversionDate">
		<xsl:param name="date"/>
		<xsl:choose>
			<xsl:when test="$date/@week = 1">
				<xsl:text>First</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@week = 2">
				<xsl:text>Second</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@week = 3">
				<xsl:text>Third</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@week = 4">
				<xsl:text>Fourth</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@week = 5">
				<xsl:text>Last</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="$date/@dayOfWeek = 0">
				<xsl:text>Sunday</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@dayOfWeek = 1">
				<xsl:text>Monday</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@dayOfWeek = 2">
				<xsl:text>Tuesday</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@dayOfWeek = 3">
				<xsl:text>Wednesday</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@dayOfWeek = 4">
				<xsl:text>Thursday</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@dayOfWeek = 5">
				<xsl:text>Friday</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@dayOfWeek = 6">
				<xsl:text>Saturday</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text> in </xsl:text>
		<xsl:choose>
			<xsl:when test="$date/@month = 1">
				<xsl:text>January</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 2">
				<xsl:text>February</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 3">
				<xsl:text>March</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 4">
				<xsl:text>April</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 5">
				<xsl:text>May</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 6">
				<xsl:text>June</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 7">
				<xsl:text>July</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 8">
				<xsl:text>August</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 9">
				<xsl:text>September</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 10">
				<xsl:text>October</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 11">
				<xsl:text>November</xsl:text>
			</xsl:when>
			<xsl:when test="$date/@month = 12">
				<xsl:text>December</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="PrintDate">
		<xsl:param name="dateTime"/>
		<xsl:variable name="date" select="substring-before($dateTime, 'T')"/>
		
		<xsl:variable name="year"   select="substring-before($date, '-')"/>
		<xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')"/>
		<xsl:variable name="day"    select="substring-after( substring-after($date, '-'), '-')"/>
		
		<xsl:value-of select="$month"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$day"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$year"/>
	</xsl:template>

	<xsl:template name="PrintTime">
		<xsl:param name="dateTime"/>
		<xsl:variable name="date" select="substring-before($dateTime, 'T')"/>
		<xsl:variable name="time" select="substring-before(substring-after($dateTime, 'T'), '.')"/>
		
		<xsl:variable name="hour"   select="substring-before($time, ':')"/>
		<xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')"/>
		<xsl:variable name="second" select="substring-after( substring-after($time, ':'), ':')"/>
		
		<xsl:value-of select="$hour"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$minute"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$second"/>
	</xsl:template>

	<xsl:template name="PrintBias">
		<xsl:param name="bias"/>
		
		<xsl:if test="$bias/@negative = 'true'">
			<xsl:text>-</xsl:text>
		</xsl:if>
		
		<xsl:value-of select="substring-before(substring-after($bias, 'T'), 'H')"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="substring-before(substring-after($bias, 'H'), 'M')"/>
		<xsl:text> (hours:minutes)</xsl:text>
	</xsl:template>
</xsl:transform>
