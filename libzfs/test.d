import std.stdio;
import std.file;
import std.path;

void main()
{
	auto entries=dirEntries("/proc/self/mounts","*",SpanMode.depth);
	foreach(entry;entries)
		writeln(entry);
}
