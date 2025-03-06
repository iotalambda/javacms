"use client";

import { PropsWithChildren, useState } from "react";
import MenuIcon from "public/icons/menu48.inline.svg";
import LockIcon from "public/icons/lock48.inline.svg";
import LockOpenIcon from "public/icons/lockopen48.inline.svg";
import Link from "next/link";

export function MenuView({ children }: PropsWithChildren) {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isMenuLocked, setIsMenuLocked] = useState(false);

  return (
    <div className="relative size-full">
      <div
        className={`size-full transition-padding-left duration-100 ${
          isMenuLocked ? "pl-80" : "pl-0"
        }`}
      >
        <div className="p-2">{children}</div>
      </div>
      <div
        className={`fixed w-80 top-0 left-0 h-full bg-white border-r-2 border-black transition-[opacity,box-shadow] duration-100 ${
          isMenuOpen ? "opacity-100" : "opacity-0 pointer-events-none"
        } ${isMenuLocked ? "shadow-none" : "shadow-2xl"}`}
      >
        <div className="flex flex-col pt-20 p-3">
          <Link
            href="/"
            className="flex flex-row font-mono rounded-2xl p-3 transition-colors duration-200 hover:bg-slate-400 hover:text-white"
          >
            Main
          </Link>
          <Link
            href="/users"
            className="flex flex-row font-mono rounded-2xl p-3 transition-colors duration-200 hover:bg-slate-400 hover:text-white"
          >
            Users
          </Link>
        </div>
      </div>
      <div className="fixed top-0 left-0 pt-3 pl-3 flex flex-col">
        <div className="flex flex-row">
          <div
            className={`transition-[opacity,max-width,padding-right] duration-100 overflow-x-hidden ${
              isMenuLocked
                ? "opacity-0 max-w-0 pr-0"
                : "opacity-100 max-w-full pr-3"
            }`}
          >
            <button
              className={`rounded-md bg-white active:bg-slate-100 aspect-square border-2 border-black ${
                isMenuOpen
                  ? ""
                  : "transition-opacity duration-100 opacity-0 hover:opacity-100"
              }`}
              onClick={() => setIsMenuOpen((v) => !v)}
            >
              <MenuIcon />
            </button>
          </div>
          <div className="pr-3">
            <button
              className={`rounded-md bg-white active:bg-slate-100 aspect-square border-2 border-black transition-opacity duration-100 ${
                isMenuOpen ? "opacity-100" : "opacity-0 pointer-events-none"
              }`}
              onClick={() => setIsMenuLocked((v) => !v)}
            >
              {isMenuLocked ? <LockIcon /> : <LockOpenIcon />}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
